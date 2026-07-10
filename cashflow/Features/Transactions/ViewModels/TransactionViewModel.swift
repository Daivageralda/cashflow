import Observation
import SwiftData
import Foundation

enum TransactionFilter {
    case all
    case income
    case expense
    case category(Category)
}

enum TransactionSort {
    case dateDesc
    case dateAsc
    case amountDesc
    case amountAsc
}

@Observable
@MainActor
final class TransactionViewModel {
    var transactions: [Transaction] = []
    var selectedFilter: TransactionFilter = .all
    var selectedSort: TransactionSort = .dateDesc
    var searchQuery: String = ""
    var isLoading: Bool = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetch()
    }

    func fetch() {
        var descriptor = FetchDescriptor<Transaction>()

        switch selectedSort {
        case .dateDesc:   descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        case .dateAsc:    descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]
        case .amountDesc: descriptor.sortBy = [SortDescriptor(\.amount, order: .reverse)]
        case .amountAsc:  descriptor.sortBy = [SortDescriptor(\.amount, order: .forward)]
        }

        let all = (try? modelContext.fetch(descriptor)) ?? []

        transactions = all.filter { tx in
            let passesFilter: Bool = {
                switch selectedFilter {
                case .all:               return true
                case .income:            return tx.type == .income
                case .expense:           return tx.type == .expense
                case .category(let cat): return tx.category?.id == cat.id
                }
            }()

            let passesSearch: Bool = searchQuery.isEmpty
                || tx.note.localizedCaseInsensitiveContains(searchQuery)
                || (tx.category?.name.localizedCaseInsensitiveContains(searchQuery) ?? false)

            return passesFilter && passesSearch
        }
    }

    func add(amount: Double, type: TransactionType, note: String, date: Date, category: Category?) {
        let tx = Transaction(amount: amount, type: type, note: note, date: date, category: category)
        modelContext.insert(tx)
        try? modelContext.save()
        fetch()
    }

    func update(_ transaction: Transaction, amount: Double, type: TransactionType, note: String, date: Date, category: Category?) {
        transaction.amount = amount
        transaction.type = type
        transaction.note = note
        transaction.date = date
        transaction.category = category
        try? modelContext.save()
        fetch()
    }

    func delete(_ transaction: Transaction) {
        modelContext.delete(transaction)
        try? modelContext.save()
        fetch()
    }

    var groupedTransactions: [(key: String, transactions: [Transaction])] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")

        let grouped = Dictionary(grouping: transactions) { tx -> String in
            if calendar.isDateInToday(tx.date) { return "Hari Ini" }
            if calendar.isDateInYesterday(tx.date) { return "Kemarin" }
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: tx.date)
        }

        let sortedKeys = grouped.keys.sorted { a, b in
            if a == "Hari Ini" { return true }
            if b == "Hari Ini" { return false }
            if a == "Kemarin" { return true }
            if b == "Kemarin" { return false }
            formatter.dateFormat = "d MMMM yyyy"
            let dateA = formatter.date(from: a) ?? .distantPast
            let dateB = formatter.date(from: b) ?? .distantPast
            return dateA > dateB
        }

        return sortedKeys.map { key in
            (key: key, transactions: grouped[key] ?? [])
        }
    }
}
