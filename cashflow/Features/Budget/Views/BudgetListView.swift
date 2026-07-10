import SwiftUI
import SwiftData

struct BudgetListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BudgetViewModel?
    @State private var showAddBudget: Bool = false
    @State private var selectedBudget: BudgetStatus? = nil

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.budgets.isEmpty {
                        EmptyStateView(
                            icon: "target",
                            title: "Belum ada budget",
                            description: "Buat budget pengeluaran per kategori untuk membatasi pengeluaran bulananmu.",
                            actionTitle: "Buat Budget Pertama",
                            action: { showAddBudget = true }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: Spacing.s24) {
                                overallSummaryCard(vm: vm)

                                budgetListSection(vm: vm)
                            }
                            .padding(.vertical, Spacing.s16)
                        }
                    }
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddBudget, onDismiss: { viewModel?.refresh() }) {
                if let vm = viewModel {
                    AddEditBudgetView(viewModel: vm)
                }
            }
            .sheet(item: $selectedBudget) { status in
                BudgetDetailView(budgetStatus: status, onDelete: {
                    if let vm = viewModel {
                        vm.deleteBudget(status.budget)
                    }
                    selectedBudget = nil
                })
            }
        }
        .task {
            if viewModel == nil {
                viewModel = BudgetViewModel(modelContext: modelContext)
            }
            viewModel?.refresh()
        }
    }

    private func overallSummaryCard(vm: BudgetViewModel) -> some View {
        let totalRatio = vm.totalBudgetLimit > 0 ? vm.totalSpent / vm.totalBudgetLimit : 0.0

        return VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("Pengeluaran Bulanan vs Total Budget")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            VStack(spacing: Spacing.s8) {
                HStack(alignment: .lastTextBaseline) {
                    Text(vm.totalSpent.formatted(.currency(code: "IDR").presentation(.narrow)))
                        .font(.cashflowLargeTitle)
                        .foregroundStyle(Color.textPrimary)
                        .cashflowMonospacedDigits()

                    Text("/ " + vm.totalBudgetLimit.formatted(.currency(code: "IDR").presentation(.narrow)))
                        .font(.cashflowBody)
                        .foregroundStyle(Color.textTertiary)
                        .cashflowMonospacedDigits()
                }

                BudgetProgressBar(ratio: totalRatio, height: 10)
            }

            HStack {
                Text(totalRatio >= 1.0 ? "Overspent!" : "Tersisa")
                    .font(.cashflowFootnote)
                    .foregroundStyle(totalRatio >= 1.0 ? Color.stateCritical : Color.textSecondary)

                Spacer()

                let diff = vm.totalBudgetLimit - vm.totalSpent
                Text(abs(diff).formatted(.currency(code: "IDR").presentation(.narrow)))
                    .font(.cashflowSubheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(totalRatio >= 1.0 ? Color.stateCritical : Color.stateSuccess)
                    .cashflowMonospacedDigits()
            }
        }
        .padding(Spacing.s20)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, Spacing.s16)
    }

    private func budgetListSection(vm: BudgetViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Daftar Anggaran Kategori")
                .font(.cashflowHeadline)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.s16)

            VStack(spacing: Spacing.s12) {
                ForEach(vm.budgets) { status in
                    budgetRow(status)
                }
            }
            .padding(.horizontal, Spacing.s16)
        }
    }

    private func budgetRow(_ status: BudgetStatus) -> some View {
        Button {
            selectedBudget = status
        } label: {
            VStack(spacing: Spacing.s12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(hex: status.category.colorHex).opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: status.category.icon)
                            .foregroundStyle(Color(hex: status.category.colorHex))
                    }

                    Text(status.category.name)
                        .font(.cashflowSubheadline)
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    Text("\(Int(status.ratio * 100))%")
                        .font(.cashflowCaption1)
                        .foregroundStyle(escalationColor(for: status.ratio))
                }

                BudgetProgressBar(ratio: status.ratio, height: 6)

                HStack {
                    Text(status.spent.formatted(.currency(code: "IDR").presentation(.narrow)))
                        .font(.cashflowFootnote)
                        .foregroundStyle(Color.textPrimary)
                        .cashflowMonospacedDigits()

                    Spacer()

                    Text("/ " + status.budget.limit.formatted(.currency(code: "IDR").presentation(.narrow)))
                        .font(.cashflowFootnote)
                        .foregroundStyle(Color.textTertiary)
                        .cashflowMonospacedDigits()
                }
            }
            .padding(Spacing.s16)
            .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
    }

    private func escalationColor(for ratio: Double) -> Color {
        if ratio >= 1.0 { return Color.stateCritical }
        if ratio >= 0.8 { return Color.stateCaution }
        return Color.accentSecondary
    }
}
