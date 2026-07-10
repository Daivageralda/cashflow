import SwiftData
import Foundation

@Model
final class Bill {
    var id: UUID
    var name: String
    var amount: Double
    var dueDay: Int             // 1–31
    var isRecurring: Bool
    var lastPaidAt: Date?
    var notificationIdentifiers: [String]
    var category: Category?

    init(name: String, amount: Double, dueDay: Int, isRecurring: Bool = true, category: Category? = nil) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.dueDay = dueDay
        self.isRecurring = isRecurring
        self.lastPaidAt = nil
        self.notificationIdentifiers = []
        self.category = category
    }

    var dueDate: Date {
        let calendar = Calendar.current
        let now = Date.now
        let range = calendar.range(of: .day, in: .month, for: now)
        let maxDay = range?.count ?? 30
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = min(dueDay, maxDay)
        components.hour = 9
        components.minute = 0
        return calendar.date(from: components) ?? now
    }

    var isPaid: Bool {
        guard let lastPaidAt else { return false }
        let calendar = Calendar.current
        return calendar.isDate(lastPaidAt, equalTo: Date.now, toGranularity: .month)
    }
}
