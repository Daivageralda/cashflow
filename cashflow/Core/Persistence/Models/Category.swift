import SwiftData
import Foundation

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String        // SF Symbol name
    var colorHex: String    // hex string
    var isSystem: Bool      // true = system default, false = custom
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]

    @Relationship(deleteRule: .nullify, inverse: \Budget.category)
    var budgets: [Budget]

    init(name: String, icon: String, colorHex: String, isSystem: Bool = false, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isSystem = isSystem
        self.sortOrder = sortOrder
        self.transactions = []
        self.budgets = []
    }
}

extension Category {
    static let systemCategories: [(name: String, icon: String, colorHex: String)] = [
        ("Makanan",      "fork.knife",           "#C96B2C"),
        ("Transport",    "car.fill",              "#6B4B2A"),
        ("Belanja",      "bag.fill",              "#E89A45"),
        ("Hiburan",      "gamecontroller.fill",   "#7A8B5C"),
        ("Tagihan",      "bolt.fill",             "#5C5A54"),
        ("Kesehatan",    "heart.fill",            "#A8492C"),
        ("Pendapatan",   "arrow.down.circle.fill","#7A8B5C"),
        ("Lainnya",      "ellipsis.circle.fill",  "#8A877E"),
    ]
}
