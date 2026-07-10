import Observation
import SwiftData
import Foundation

struct CategoryReport: Identifiable {
    let id: UUID
    let categoryName: String
    let colorHex: String
    let totalAmount: Double
    let percentage: Double
}

struct DailyTrend: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct MonthlyComparison: Identifiable {
    let id = UUID()
    let monthName: String
    let income: Double
    let expense: Double
}

@Observable
@MainActor
final class ReportsViewModel {
    var categoryReports: [CategoryReport] = []
    var dailyTrends: [DailyTrend] = []
    var monthlyComparisons: [MonthlyComparison] = []
    var generatedInsight: String = ""

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task { await refresh() }
    }

    func refresh() async {
        loadCategoryBreakdown()
        loadDailyTrends()
        loadMonthlyComparisons()
        await generateSimpleInsight()
    }

    private func loadCategoryBreakdown() {
        let calendar = Calendar.current
        let now = Date.now
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let descriptor = FetchDescriptor<Transaction>()
        let all = (try? modelContext.fetch(descriptor)) ?? []

        // Filter pengeluaran bulan ini
        let currentExpenses = all.filter { tx in
            tx.type == .expense &&
            calendar.component(.month, from: tx.date) == currentMonth &&
            calendar.component(.year, from: tx.date) == currentYear
        }

        let totalExpense = currentExpenses.reduce(0.0) { $0 + $1.amount }

        let grouped = Dictionary(grouping: currentExpenses) { $0.category?.id ?? UUID() }

        categoryReports = grouped.compactMap { key, txs in
            guard let firstTx = txs.first, let category = firstTx.category else { return nil }
            let sum = txs.reduce(0.0) { $0 + $1.amount }
            let percent = totalExpense > 0 ? (sum / totalExpense) * 100 : 0.0
            return CategoryReport(
                id: category.id,
                categoryName: category.name,
                colorHex: category.colorHex,
                totalAmount: sum,
                percentage: percent
            )
        }
        .sorted { $0.totalAmount > $1.totalAmount }
    }

    private func loadDailyTrends() {
        let calendar = Calendar.current
        let now = Date.now
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now

        let descriptor = FetchDescriptor<Transaction>()
        let all = (try? modelContext.fetch(descriptor)) ?? []

        let last30DaysExpenses = all.filter { tx in
            tx.type == .expense && tx.date >= thirtyDaysAgo
        }

        let grouped = Dictionary(grouping: last30DaysExpenses) { tx -> Date in
            calendar.startOfDay(for: tx.date)
        }

        dailyTrends = (0..<30).map { dayOffset -> DailyTrend in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: now)) ?? now
            let amount = grouped[date]?.reduce(0.0) { $0 + $1.amount } ?? 0.0
            return DailyTrend(date: date, amount: amount)
        }
        .sorted { $0.date < $1.date }
    }

    private func loadMonthlyComparisons() {
        let calendar = Calendar.current
        let now = Date.now

        let descriptor = FetchDescriptor<Transaction>()
        let all = (try? modelContext.fetch(descriptor)) ?? []

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMM"

        monthlyComparisons = (0..<6).map { monthOffset -> MonthlyComparison in
            let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) ?? now
            let m = calendar.component(.month, from: date)
            let y = calendar.component(.year, from: date)

            let monthTxs = all.filter { tx in
                calendar.component(.month, from: tx.date) == m &&
                calendar.component(.year, from: tx.date) == y
            }

            let inc = monthTxs.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
            let exp = monthTxs.filter { $0.type == .expense }.reduce(0.0) { $0 + $1.amount }

            return MonthlyComparison(monthName: formatter.string(from: date), income: inc, expense: exp)
        }
        .reversed()
    }

    private func generateSimpleInsight() async {
        let totalCurrentExpense = categoryReports.reduce(0.0) { $0 + $1.totalAmount }
        if totalCurrentExpense == 0 {
            generatedInsight = "Belum ada pengeluaran bulan ini. Anggaranmu aman!"
            return
        }

        let summary = categoryReports.map { "- \($0.categoryName): \($0.totalAmount.formatted(.currency(code: "IDR").presentation(.narrow)))" }.joined(separator: "\n")
        let desc = "Berikut adalah ringkasan pengeluaran bulan ini:\n\(summary)"

        generatedInsight = "Menganalisis pengeluaran..."
        let ai = AIAdvisorService()
        let result = await ai.getReportsInsight(expensesDescription: desc)
        generatedInsight = result
    }
}
