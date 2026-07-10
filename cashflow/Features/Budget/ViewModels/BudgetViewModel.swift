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

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let calendar = Calendar.current
        let now = Date.now
        self.selectedMonth = calendar.component(.month, from: now)
        self.selectedYear = calendar.component(.year, from: now)
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == selectedMonth && $0.year == selectedYear }
        )
        let rawBudgets = (try? modelContext.fetch(descriptor)) ?? []

        let calendar = Calendar.current
        let txDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date)]
        )
        let transactions = (try? modelContext.fetch(txDescriptor)) ?? []

        budgets = rawBudgets.compactMap { budget in
            guard let category = budget.category else { return nil }

            let spent = transactions
                .filter { tx in
                    tx.type == .expense &&
                    tx.category?.id == category.id &&
                    calendar.component(.month, from: tx.date) == selectedMonth &&
                    calendar.component(.year, from: tx.date) == selectedYear
                }
                .reduce(0.0) { $0 + $1.amount }

            return BudgetStatus(id: budget.id, budget: budget, category: category, spent: spent)
        }

        totalBudgetLimit = budgets.reduce(0.0) { $0 + $1.budget.limit }
        totalSpent = budgets.reduce(0.0) { $0 + $1.spent }
    }

    func addBudget(limit: Double, category: Category) {
        // Cek dulu apakah budget untuk kategori ini sudah ada di bulan/tahun terpilih
        if let existing = budgets.first(where: { $0.category.id == category.id })?.budget {
            existing.limit = limit
        } else {
            let budget = Budget(limit: limit, month: selectedMonth, year: selectedYear, category: category)
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
}
