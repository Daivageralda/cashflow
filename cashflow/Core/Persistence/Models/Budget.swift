import SwiftData
import Foundation

@Model
final class Budget {
    var id: UUID
    var limit: Double
    var month: Int      // 1–12
    var year: Int

    @Relationship(deleteRule: .nullify)
    var category: Category?

    init(limit: Double, month: Int, year: Int, category: Category? = nil) {
        self.id = UUID()
        self.limit = limit
        self.month = month
        self.year = year
        self.category = category
    }
}
