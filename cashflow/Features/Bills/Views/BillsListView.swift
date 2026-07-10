import SwiftUI
import SwiftData

struct BillsListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BillsViewModel?
    @State private var showAddBill: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.unpaidBills.isEmpty && vm.paidBills.isEmpty {
                        EmptyStateView(
                            icon: "creditcard",
                            title: "Tidak ada tagihan",
                            description: "Catat tagihan bulananmu seperti listrik, internet, atau langganan lainnya.",
                            actionTitle: "Tambah Tagihan",
                            action: { showAddBill = true }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            if !vm.unpaidBills.isEmpty {
                                Section("Belum Dibayar") {
                                    ForEach(vm.unpaidBills) { bill in
                                        billRow(bill, vm: vm)
                                    }
                                }
                            }

                            if !vm.paidBills.isEmpty {
                                Section("Lunas Bulan Ini") {
                                    ForEach(vm.paidBills) { bill in
                                        billRow(bill, vm: vm)
                                            .opacity(0.6)
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
            .background(Color.bgPrimary)
            .navigationTitle("Tagihan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddBill = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddBill, onDismiss: { viewModel?.refresh() }) {
                if let vm = viewModel {
                    AddEditBillView(viewModel: vm)
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = BillsViewModel(modelContext: modelContext)
            }
            let _ = await NotificationManager.shared.requestAuthorization()
            viewModel?.refresh()
        }
    }

    private func billRow(_ bill: Bill, vm: BillsViewModel) -> some View {
        HStack(spacing: Spacing.s12) {
            ZStack {
                Circle()
                    .fill(Color(hex: bill.category?.colorHex ?? "#8A877E").opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: bill.category?.icon ?? "doc.plaintext")
                    .foregroundStyle(Color(hex: bill.category?.colorHex ?? "#8A877E"))
            }

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(bill.name)
                    .font(.cashflowSubheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)

                Text("Jatuh tempo: Tanggal \(bill.dueDay) (Setiap Bulan)")
                    .font(.cashflowCaption1)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.s4) {
                Text(bill.amount.formatted(.currency(code: "IDR").presentation(.narrow)))
                    .font(.cashflowSubheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                    .cashflowMonospacedDigits()

                if !bill.isPaid {
                    Button("Bayar") {
                        withAnimation {
                            vm.markAsPaid(bill)
                        }
                    }
                    .font(.cashflowCaption1)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, Spacing.s12)
                    .padding(.vertical, Spacing.s4)
                    .background(Color.accentPrimary, in: Capsule())
                } else {
                    Text("Lunas")
                        .font(.cashflowCaption1)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.stateSuccess)
                }
            }
        }
        .padding(.vertical, Spacing.s4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                vm.deleteBill(bill)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
    }
}
