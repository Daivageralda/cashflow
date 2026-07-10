import Observation
import SwiftData
import Foundation

@Observable
@MainActor
final class BillsViewModel {
    var unpaidBills: [Bill] = []
    var paidBills: [Bill] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<Bill>()
        let all = (try? modelContext.fetch(descriptor)) ?? []

        // Urutkan berdasarkan dueDay
        let sorted = all.sorted { $0.dueDay < $1.dueDay }

        unpaidBills = sorted.filter { !$0.isPaid }
        paidBills = sorted.filter { $0.isPaid }
    }

    func addBill(name: String, amount: Double, dueDay: Int, category: Category?) {
        let bill = Bill(name: name, amount: amount, dueDay: dueDay, category: category)
        modelContext.insert(bill)
        try? modelContext.save()

        NotificationManager.shared.scheduleBillReminder(
            billId: bill.id.uuidString,
            title: bill.name,
            amount: bill.amount,
            dueDate: bill.dueDate,
            frequency: "Bulanan"
        )

        refresh()
    }

    func markAsPaid(_ bill: Bill) {
        bill.lastPaidAt = .now

        // Catat sebagai transaksi pengeluaran otomatis
        let tx = Transaction(
            amount: bill.amount,
            type: .expense,
            note: "Pembayaran tagihan: \(bill.name)",
            date: .now,
            category: bill.category
        )
        modelContext.insert(tx)

        try? modelContext.save()

        // Perbarui pengingat notifikasi untuk bulan depan
        NotificationManager.shared.cancelBillReminder(billId: bill.id.uuidString)
        NotificationManager.shared.scheduleBillReminder(
            billId: bill.id.uuidString,
            title: bill.name,
            amount: bill.amount,
            dueDate: bill.dueDate,
            frequency: "Bulanan"
        )

        refresh()
    }

    func deleteBill(_ bill: Bill) {
        NotificationManager.shared.cancelBillReminder(billId: bill.id.uuidString)
        modelContext.delete(bill)
        try? modelContext.save()
        refresh()
    }
}
