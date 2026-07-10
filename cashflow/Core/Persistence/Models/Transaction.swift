import SwiftData
import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"
}

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var type: TransactionType
    var note: String
    var date: Date
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var category: Category?

    init(
        amount: Double,
        type: TransactionType,
        note: String = "",
        date: Date = .now,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.note = note
        self.date = date
        self.createdAt = .now
        self.category = category
    }
}
