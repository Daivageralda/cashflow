import SwiftData
import Foundation

@Model
final class Budget {
    var id: UUID
    var limit: Double
    var month: Int      // 1–12
    var year: Int
    var period: String = "monthly" // "monthly" or "weekly"
    var weekStartDate: Date?

    @Relationship(deleteRule: .nullify)
    var category: Category?

    init(
        limit: Double,
        month: Int,
        year: Int,
        period: String = "monthly",
        weekStartDate: Date? = nil,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.limit = limit
        self.month = month
        self.year = year
        self.period = period
        self.weekStartDate = weekStartDate
        self.category = category
    }
}
