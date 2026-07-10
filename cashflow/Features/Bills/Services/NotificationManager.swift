import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleBillReminder(billId: String, title: String, amount: Double, dueDate: Date, frequency: String) {
        let content = UNMutableNotificationContent()
        content.title = "Pengingat Tagihan"
        content.body = "Tagihan \(title) sebesar \(amount.formatted(.currency(code: "IDR").presentation(.narrow))) jatuh tempo segera!"
        content.sound = .default

        let calendar = Calendar.current
        var components = DateComponents()

        if frequency == "Mingguan" {
            // Schedule weekly on the day of week of due date
            components.weekday = calendar.component(.weekday, from: dueDate)
            components.hour = 9
            components.minute = 0
        } else {
            // Schedule monthly on the day of month
            components.day = calendar.component(.day, from: dueDate)
            components.hour = 9
            components.minute = 0
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: billId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelBillReminder(billId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [billId])
    }
}
