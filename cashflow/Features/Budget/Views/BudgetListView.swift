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
                    @Bindable var bindableVM = vm
                    VStack(spacing: 0) {
                        Picker("Periode", selection: $bindableVM.selectedPeriod) {
                            Text("Bulanan").tag("monthly")
                            Text("Mingguan").tag("weekly")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Spacing.s16)
                        .padding(.bottom, Spacing.s12)
                        .onChange(of: vm.selectedPeriod) { _, _ in
                            vm.refresh()
                        }

                        if vm.selectedPeriod == "weekly" {
                            weekSelector(vm: vm)
                                .padding(.bottom, Spacing.s12)
                        } else {
                            monthSelector(vm: vm)
                                .padding(.bottom, Spacing.s12)
                        }

                        if vm.budgets.isEmpty {
                            EmptyStateView(
                                icon: "target",
                                title: "Belum ada budget",
                                description: vm.selectedPeriod == "weekly"
                                    ? "Buat budget pengeluaran per kategori untuk membatasi pengeluaran mingguanmu."
                                    : "Buat budget pengeluaran per kategori untuk membatasi pengeluaran bulananmu.",
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

    private func weekSelector(vm: BudgetViewModel) -> some View {
        HStack {
            Button {
                adjustWeek(vm: vm, days: -7)
            } label: {
                Image(systemName: "chevron.left")
                    .padding(Spacing.s8)
                    .background(Color.bgSecondary, in: Circle())
            }
            .foregroundStyle(Color.textPrimary)

            Spacer()

            Text(weekRangeString(from: vm.selectedWeekStart))
                .font(.cashflowSubheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button {
                adjustWeek(vm: vm, days: 7)
            } label: {
                Image(systemName: "chevron.right")
                    .padding(Spacing.s8)
                    .background(Color.bgSecondary, in: Circle())
            }
            .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, Spacing.s16)
    }

    private func adjustWeek(vm: BudgetViewModel, days: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: days, to: vm.selectedWeekStart) {
            vm.changeWeek(weekStart: newDate)
        }
    }

    private func weekRangeString(from start: Date) -> String {
        let calendar = Calendar.current
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    private func monthSelector(vm: BudgetViewModel) -> some View {
        HStack {
            Button {
                adjustMonth(vm: vm, delta: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .padding(Spacing.s8)
                    .background(Color.bgSecondary, in: Circle())
            }
            .foregroundStyle(Color.textPrimary)

            Spacer()

            Text(monthString(month: vm.selectedMonth, year: vm.selectedYear))
                .font(.cashflowSubheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button {
                adjustMonth(vm: vm, delta: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .padding(Spacing.s8)
                    .background(Color.bgSecondary, in: Circle())
            }
            .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, Spacing.s16)
    }

    private func adjustMonth(vm: BudgetViewModel, delta: Int) {
        var newMonth = vm.selectedMonth + delta
        var newYear = vm.selectedYear
        if newMonth > 12 {
            newMonth = 1
            newYear += 1
        } else if newMonth < 1 {
            newMonth = 12
            newYear -= 1
        }
        vm.changePeriod(month: newMonth, year: newYear)
    }

    private func monthString(month: Int, year: Int) -> String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = month
        components.year = year
        if let date = calendar.date(from: components) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
        return "\(month) / \(year)"
    }

    private func overallSummaryCard(vm: BudgetViewModel) -> some View {
        let totalRatio = vm.totalBudgetLimit > 0 ? vm.totalSpent / vm.totalBudgetLimit : 0.0

        return VStack(alignment: .leading, spacing: Spacing.s16) {
            Text(vm.selectedPeriod == "weekly" ? "Pengeluaran Mingguan vs Total Budget" : "Pengeluaran Bulanan vs Total Budget")
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
