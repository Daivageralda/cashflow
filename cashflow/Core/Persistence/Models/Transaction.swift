import SwiftData
import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"
}

enum SyncState: String, Codable {
    case synced = "synced"
    case pendingUpload = "pendingUpload"
    case pendingDelete = "pendingDelete"
}

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var type: TransactionType
    var note: String
    var date: Date
    var createdAt: Date
    var updatedAt: Date?
    var syncStateValue: String = SyncState.pendingUpload.rawValue
    var remoteImagePath: String?

    var syncState: SyncState {
        get { SyncState(rawValue: syncStateValue) ?? .pendingUpload }
        set { syncStateValue = newValue.rawValue }
    }

    var latitude: Double?
    var longitude: Double?
    var locationName: String?

    @Attribute(.externalStorage)
    var attachmentImageData: Data?

    @Relationship(deleteRule: .nullify)
    var category: Category?

    init(
        amount: Double,
        type: TransactionType,
        note: String = "",
        date: Date = .now,
        category: Category? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil,
        attachmentImageData: Data? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.note = note
        self.date = date
        self.createdAt = .now
        self.updatedAt = .now
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.attachmentImageData = attachmentImageData
    }
}
