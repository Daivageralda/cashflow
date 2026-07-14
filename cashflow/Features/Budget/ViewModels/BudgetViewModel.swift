import Observation
import SwiftData
import Foundation

struct BudgetStatus: Identifiable {
    let id: UUID
    let budget: Budget
    let category: Category
    let spent: Double
    var ratio: Double { spent / max(budget.limit, 1.0) }
    var remaining: Double { max(budget.limit - spent, 0.0) }
    var isOverspent: Bool { spent > budget.limit }
}

@Observable
@MainActor
final class BudgetViewModel {
    var budgets: [BudgetStatus] = []
    var totalBudgetLimit: Double = 0
    var totalSpent: Double = 0
    var selectedMonth: Int
    var selectedYear: Int
    var selectedPeriod: String = "monthly" // "monthly" or "weekly"
    var selectedWeekStart: Date

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let calendar = Calendar.current
        let now = Date.now
        self.selectedMonth = calendar.component(.month, from: now)
        self.selectedYear = calendar.component(.year, from: now)

        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        self.selectedWeekStart = calendar.date(from: components) ?? now
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<Budget>()
        let rawBudgets = (try? modelContext.fetch(descriptor)) ?? []

        let calendar = Calendar.current
        let txDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date)]
        )
        let transactions = (try? modelContext.fetch(txDescriptor)) ?? []

        let filteredRawBudgets = rawBudgets.filter { budget in
            if selectedPeriod == "weekly" {
                guard budget.period == "weekly", let weekStart = budget.weekStartDate else { return false }
                return calendar.isDate(weekStart, inSameDayAs: selectedWeekStart)
            } else {
                return budget.period == "monthly" && budget.month == selectedMonth && budget.year == selectedYear
            }
        }

        budgets = filteredRawBudgets.compactMap { budget in
            guard let category = budget.category else { return nil }

            let spent = transactions
                .filter { tx in
                    guard tx.type == .expense && tx.category?.id == category.id else { return false }

                    if selectedPeriod == "weekly" {
                        guard let weekStart = budget.weekStartDate else { return false }
                        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
                        return tx.date >= weekStart && tx.date < weekEnd
                    } else {
                        return calendar.component(.month, from: tx.date) == selectedMonth &&
                               calendar.component(.year, from: tx.date) == selectedYear
                    }
                }
                .reduce(0.0) { $0 + $1.amount }

            return BudgetStatus(id: budget.id, budget: budget, category: category, spent: spent)
        }

        totalBudgetLimit = budgets.reduce(0.0) { $0 + $1.budget.limit }
        totalSpent = budgets.reduce(0.0) { $0 + $1.spent }
    }

    func addBudget(limit: Double, category: Category, period: String = "monthly", weekStartDate: Date? = nil) {
        if let existing = budgets.first(where: { $0.category.id == category.id })?.budget {
            existing.limit = limit
        } else {
            let budget = Budget(
                limit: limit,
                month: selectedMonth,
                year: selectedYear,
                period: period,
                weekStartDate: weekStartDate,
                category: category
            )
            modelContext.insert(budget)
        }
        try? modelContext.save()
        refresh()
    }

    func updateBudget(_ budget: Budget, limit: Double) {
        budget.limit = limit
        try? modelContext.save()
        refresh()
    }

    func deleteBudget(_ budget: Budget) {
        modelContext.delete(budget)
        try? modelContext.save()
        refresh()
    }

    func changePeriod(month: Int, year: Int) {
        self.selectedMonth = month
        self.selectedYear = year
        refresh()
    }

    func changeWeek(weekStart: Date) {
        self.selectedWeekStart = weekStart
        refresh()
    }
}
