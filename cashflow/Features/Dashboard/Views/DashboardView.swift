import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var animatedBalance: Double = 0
    @State private var showAddTransaction: Bool = false
    @State private var showScanner: Bool = false
    @State private var showAIAdvisor: Bool = false

    @AppStorage("use_expense_only_mode") private var useExpenseOnlyMode: Bool = false

    private var userName: String {
        UserDefaults.standard.string(forKey: "user_name") ?? "Kamu"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    balanceHeroCard

                    if let vm = viewModel {
                        QuickInsightCardView(message: vm.todayInsight)
                            .padding(.horizontal, Spacing.s16)
                    }

                    if let vm = viewModel, !vm.budgetSnapshots.isEmpty {
                        budgetSnapshotSection(snapshots: vm.budgetSnapshots)
                    }

                    if let vm = viewModel {
                        recentTransactionsSection(transactions: vm.recentTransactions)
                    }
                }
                .padding(.bottom, Spacing.s48)
            }
            .background(Color.bgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("text-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: Spacing.s16) {
                        Button {
                            showScanner = true
                        } label: {
                            Image(systemName: "camera.viewfinder")
                                .foregroundStyle(Color.textSecondary)
                        }

                        Button {
                            showAIAdvisor = true
                        } label: {
                            Image(systemName: "sparkles")
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentPrimary, in: Circle())
                        .shadow(color: Color.accentPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, Spacing.s24)
                .padding(.bottom, Spacing.s24)
            }
            .sheet(isPresented: $showAddTransaction, onDismiss: {
                viewModel?.refresh()
                if let bal = viewModel?.totalBalance {
                    animateBalance(to: bal)
                }
            }) {
                AddTransactionView()
            }
            .sheet(isPresented: $showScanner, onDismiss: {
                viewModel?.refresh()
                if let bal = viewModel?.totalBalance {
                    animateBalance(to: bal)
                }
            }) {
                ReceiptScannerView()
            }
            .sheet(isPresented: $showAIAdvisor) {
                AIAdvisorView()
            }

        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
            }
            viewModel?.refresh()
            animateBalance(to: viewModel?.totalBalance ?? 0)
        }
        .onChange(of: useExpenseOnlyMode) { _, _ in
            viewModel?.refresh()
            if let bal = viewModel?.totalBalance {
                animateBalance(to: bal)
            }
        }
    }

    private var balanceHeroCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(useExpenseOnlyMode ? "Total Pengeluaran" : "Saldo Kamu")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            Text(animatedBalance.formatted(.currency(code: "IDR").presentation(.narrow)))
                .font(.cashflowLargeTitle)
                .foregroundStyle(useExpenseOnlyMode ? Color.stateCritical : Color.textPrimary)
                .cashflowMonospacedDigits()
                .contentTransition(.numericText(countsDown: animatedBalance < (viewModel?.totalBalance ?? 0)))
                .animation(.easeOut(duration: 0.5), value: animatedBalance)

            Text("Halo, \(userName) 👋")
                .font(.cashflowFootnote)
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s20)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, Spacing.s16)
        .padding(.top, Spacing.s8)
    }

    private func budgetSnapshotSection(snapshots: [BudgetSnapshot]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Budget Bulan Ini")
                .font(.cashflowHeadline)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.s16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s12) {
                    ForEach(snapshots.prefix(4), id: \.budget.id) { snapshot in
                        budgetMiniCard(snapshot: snapshot)
                    }
                }
                .padding(.horizontal, Spacing.s16)
            }
        }
    }

    private func budgetMiniCard(snapshot: BudgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            HStack {
                Image(systemName: snapshot.category.icon)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("\(Int(snapshot.ratio * 100))%")
                    .font(.cashflowCaption1)
                    .foregroundStyle(escalationColor(for: snapshot.ratio))
            }
            .font(.system(size: 14, weight: .medium))

            Text(snapshot.category.name)
                .font(.cashflowCaption1)
                .foregroundStyle(Color.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.bgTertiary)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(escalationColor(for: snapshot.ratio))
                        .frame(width: geo.size.width * min(snapshot.ratio, 1.0), height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: snapshot.ratio)
                }
            }
            .frame(height: 4)
        }
        .padding(Spacing.s12)
        .frame(width: 120)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    private func recentTransactionsSection(transactions: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                Text("Transaksi Terbaru")
                    .font(.cashflowHeadline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Button("Lihat Semua") {
                    // Part 4
                }
                .font(.cashflowCallout)
                .foregroundStyle(Color.accentPrimary)
            }
            .padding(.horizontal, Spacing.s16)

            if transactions.isEmpty {
                EmptyStateView(
                    icon: "arrow.left.arrow.right.circle",
                    title: "Belum ada transaksi",
                    description: "Mulai catat pemasukan atau pengeluaranmu.",
                    actionTitle: "Catat Sekarang",
                    action: { showAddTransaction = true }
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(transactions, id: \.id) { transaction in
                        transactionRow(transaction)
                        if transaction.id != transactions.last?.id {
                            Divider()
                                .padding(.leading, Spacing.s48 + Spacing.s16)
                        }
                    }
                }
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
                .padding(.horizontal, Spacing.s16)
            }
        }
    }

    private func transactionRow(_ tx: Transaction) -> some View {
        HStack(spacing: Spacing.s12) {
            ZStack {
                Circle()
                    .fill(Color(hex: tx.category?.colorHex ?? "#8A877E").opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: tx.category?.icon ?? "questionmark.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: tx.category?.colorHex ?? "#8A877E"))
            }

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(tx.category?.name ?? "Lainnya")
                    .font(.cashflowSubheadline)
                    .foregroundStyle(Color.textPrimary)

                Text(tx.note.isEmpty ? tx.date.formatted(date: .abbreviated, time: .omitted) : tx.note)
                    .font(.cashflowFootnote)
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Text((tx.type == .income ? "+" : "-") + tx.amount.formatted(.currency(code: "IDR").presentation(.narrow)))
                .font(.cashflowSubheadline)
                .foregroundStyle(tx.type == .income ? Color.stateSuccess : Color.textPrimary)
                .cashflowMonospacedDigits()
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s12)
    }

    private func animateBalance(to target: Double) {
        withAnimation(.easeOut(duration: 0.5)) {
            animatedBalance = target
        }
    }

    private func escalationColor(for ratio: Double) -> Color {
        if ratio >= 1.0 { return Color.stateCritical }
        if ratio >= 0.8 { return Color.stateCaution }
        return Color.accentSecondary
    }
}
