import Observation
import SwiftData
import Foundation
import WidgetKit

struct BudgetSnapshot {
    let category: Category
    let budget: Budget
    let spent: Double
    var ratio: Double { spent / max(budget.limit, 1) }
}

@Observable
@MainActor
final class DashboardViewModel {
    var totalBalance: Double = 0
    var recentTransactions: [Transaction] = []
    var budgetSnapshots: [BudgetSnapshot] = []
    var todayInsight: String? = nil
    var isLoading: Bool = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func refresh() {
        loadBalance()
        loadRecentTransactions()
        loadBudgetSnapshots()
    }

    private func loadBalance() {
        let descriptor = FetchDescriptor<Transaction>()
        let all = (try? modelContext.fetch(descriptor)) ?? []

        let isExpenseOnly = UserDefaults.standard.bool(forKey: "use_expense_only_mode")
        if isExpenseOnly {
            totalBalance = all.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }
        } else {
            totalBalance = all.reduce(0.0) { result, tx in
                tx.type == .income ? result + tx.amount : result - tx.amount
            }
        }

        if let sharedDefaults = UserDefaults(suiteName: "group.com.dumeg.cashflow") {
            sharedDefaults.set(totalBalance, forKey: "totalBalance")
        }
    }

    private func loadRecentTransactions() {
        var descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        recentTransactions = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func loadBudgetSnapshots() {
        let calendar = Calendar.current
        let now = Date.now
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let budgetDescriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == currentMonth && $0.year == currentYear }
        )
        let budgets = (try? modelContext.fetch(budgetDescriptor)) ?? []

        budgetSnapshots = budgets.compactMap { budget in
            guard let category = budget.category else { return nil }
            let spent = category.transactions
                .filter { tx in
                    tx.type == .expense &&
                    calendar.component(.month, from: tx.date) == currentMonth &&
                    calendar.component(.year, from: tx.date) == currentYear
                }
                .reduce(0) { $0 + $1.amount }
            return BudgetSnapshot(category: category, budget: budget, spent: spent)
        }
        .sorted { $0.ratio > $1.ratio }

        let totalSpent = budgetSnapshots.reduce(0.0) { $0 + $1.spent }
        if let sharedDefaults = UserDefaults(suiteName: "group.com.dumeg.cashflow") {
            sharedDefaults.set(totalSpent, forKey: "totalSpent")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
