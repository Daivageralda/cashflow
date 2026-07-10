import SwiftUI
import SwiftData

struct BudgetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let budgetStatus: BudgetStatus
    var onDelete: () -> Void

    @State private var showDeleteConfirm: Bool = false
    @State private var showEditSheet: Bool = false

    @Query private var transactions: [Transaction]

    init(budgetStatus: BudgetStatus, onDelete: @escaping () -> Void) {
        self.budgetStatus = budgetStatus
        self.onDelete = onDelete

        let categoryId = budgetStatus.category.id
        _transactions = Query(filter: #Predicate<Transaction> { tx in
            tx.category?.id == categoryId
        }, sort: \Transaction.date, order: .reverse)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    HStack {
                        Text("Limit")
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(budgetStatus.budget.limit.formatted(.currency(code: "IDR").presentation(.narrow)))
                            .cashflowMonospacedDigits()
                    }

                    HStack {
                        Text("Terpakai")
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(budgetStatus.spent.formatted(.currency(code: "IDR").presentation(.narrow)))
                            .foregroundStyle(budgetStatus.isOverspent ? Color.stateCritical : Color.textPrimary)
                            .cashflowMonospacedDigits()
                    }

                    HStack {
                        Text(budgetStatus.isOverspent ? "Overspent" : "Sisa")
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(budgetStatus.remaining.formatted(.currency(code: "IDR").presentation(.narrow)))
                            .foregroundStyle(budgetStatus.isOverspent ? Color.stateCritical : Color.stateSuccess)
                            .cashflowMonospacedDigits()
                    }
                }

                Section("Riwayat Transaksi Kategori") {
                    if transactions.isEmpty {
                        Text("Belum ada transaksi di kategori ini.")
                            .font(.cashflowFootnote)
                            .foregroundStyle(Color.textTertiary)
                    } else {
                        ForEach(transactions) { tx in
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.s4) {
                                    Text(tx.note.isEmpty ? "Belum ada catatan" : tx.note)
                                        .font(.cashflowSubheadline)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(tx.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.cashflowCaption1)
                                        .foregroundStyle(Color.textTertiary)
                                }
                                Spacer()
                                Text(tx.amount.formatted(.currency(code: "IDR").presentation(.narrow)))
                                    .font(.cashflowSubheadline)
                                    .cashflowMonospacedDigits()
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Hapus Budget", systemImage: "trash")
                            .foregroundStyle(Color.stateCritical)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .navigationTitle(budgetStatus.category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tutup") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        showEditSheet = true
                    }
                    .foregroundStyle(Color.accentPrimary)
                }
            }
            .confirmationDialog(
                "Hapus budget ini?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Hapus", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Tindakan ini hanya menghapus limit budget. Riwayat transaksi kategori akan tetap aman.")
            }
        }
    }
}
