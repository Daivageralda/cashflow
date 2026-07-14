import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TransactionViewModel?
    @State private var showAddTransaction: Bool = false
    @State private var selectedTransaction: Transaction? = nil
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChipsView

                Group {
                    if let vm = viewModel {
                        if vm.groupedTransactions.isEmpty {
                            EmptyStateView(
                                icon: "arrow.left.arrow.right.circle",
                                title: "Tidak ada transaksi",
                                description: vm.searchQuery.isEmpty
                                    ? "Mulai catat transaksimu."
                                    : "Tidak ada hasil untuk \"\(vm.searchQuery)\"."
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List {
                                ForEach(vm.groupedTransactions, id: \.key) { group in
                                    Section(group.key) {
                                        ForEach(group.transactions, id: \.id) { tx in
                                            TransactionRowView(transaction: tx)
                                                .listRowInsets(EdgeInsets())
                                                .listRowBackground(Color.bgSecondary)
                                                .onTapGesture { selectedTransaction = tx }
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    Button(role: .destructive) {
                                                        withAnimation {
                                                            vm.delete(tx)
                                                        }
                                                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                                    } label: {
                                                        Label("Hapus", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .scrollContentBackground(.hidden)
                            .background(Color.bgPrimary)
                        }
                    }
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Transaksi")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: Binding(
                get: { viewModel?.searchQuery ?? "" },
                set: { viewModel?.searchQuery = $0; viewModel?.fetch() }
            ), prompt: "Cari transaksi...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction, onDismiss: { viewModel?.fetch() }) {
                AddTransactionView()
            }
            .sheet(item: $selectedTransaction) { tx in
                TransactionDetailView(transaction: tx, onDelete: {
                    withAnimation {
                        viewModel?.delete(tx)
                    }
                    selectedTransaction = nil
                })
            }
        }
        .task {
            if viewModel == nil {
                viewModel = TransactionViewModel(modelContext: modelContext)
            }
        }
    }

    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s8) {
                filterChip("Semua", filter: .all)
                filterChip("Pemasukan", filter: .income)
                filterChip("Pengeluaran", filter: .expense)

                ForEach(categories.filter { !$0.isSystem || $0.name == "Lainnya" }.prefix(5), id: \.id) { cat in
                    filterChip(cat.name, filter: .category(cat))
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.vertical, Spacing.s12)
        }
    }

    private func filterChip(_ label: String, filter: TransactionFilter) -> some View {
        let isSelected: Bool = {
            switch (viewModel?.selectedFilter, filter) {
            case (.all, .all): return true
            case (.income, .income): return true
            case (.expense, .expense): return true
            case (.category(let a), .category(let b)): return a.id == b.id
            default: return false
            }
        }()

        return Button {
            viewModel?.selectedFilter = filter
            viewModel?.fetch()
        } label: {
            Text(label)
                .font(.cashflowSubheadline)
                .foregroundStyle(isSelected ? Color.white : Color.textSecondary)
                .padding(.horizontal, Spacing.s12)
                .padding(.vertical, Spacing.s8)
                .background(
                    isSelected ? Color.accentPrimary : Color.bgSecondary,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}
