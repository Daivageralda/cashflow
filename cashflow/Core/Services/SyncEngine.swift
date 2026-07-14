import Foundation
import SwiftData
import Combine
import Network
import Supabase
import PostgREST
import Auth

struct CategorySyncPayload: Codable {
    let id: String
    let user_id: String
    let name: String
    let icon: String
    let color_hex: String
    let is_system: Bool
    let sort_order: Int
    let updated_at: String
}

struct TransactionSyncPayload: Codable {
    let id: String
    let user_id: String
    let amount: Double
    let type: String
    let note: String
    let date: String
    let category_id: String?
    let image_path: String?
    let location_latitude: Double?
    let location_longitude: Double?
    let updated_at: String
}

struct BudgetSyncPayload: Codable {
    let id: String
    let user_id: String
    let amount: Double
    let category_id: String?
    let period: String
    let start_date: String?
    let updated_at: String
}

struct BillSyncPayload: Codable {
    let id: String
    let user_id: String
    let title: String
    let amount: Double
    let due_date: String
    let is_paid: Bool
    let category_id: String?
    let updated_at: String
}

@MainActor
final class SyncEngine: ObservableObject {
    static let shared = SyncEngine()

    private let supabase = SupabaseService.shared
    private var container: ModelContainer?
    private var cancellables = Set<AnyCancellable>()
    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "SyncEngineMonitor")
    
    @Published var lastSyncedAt: Date? {
        didSet {
            if let date = lastSyncedAt {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "last_synced_timestamp")
            }
        }
    }
    @Published var isSyncing = false
    @Published var isOnline = true
    @Published var totalDataSyncedBytes: Int64 = 0
    @Published var syncStatusMessage: String = "Siap untuk sinkronisasi"

    private init() {
        self.totalDataSyncedBytes = Int64(UserDefaults.standard.integer(forKey: "total_synced_bytes"))
        if let timestamp = UserDefaults.standard.object(forKey: "last_synced_timestamp") as? Double {
            self.lastSyncedAt = Date(timeIntervalSince1970: timestamp)
        }
        
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    await self?.triggerSync()
                }
            }
        }
        pathMonitor.start(queue: queue)
    }

    func setup(with container: ModelContainer) {
        self.container = container
        
        // Auto-signin anonim jika belum terautentikasi
        Task {
            if !supabase.isAuthenticated {
                try? await supabase.signInAnonymously()
            }
        }
    }

    func triggerSync() async {
        print("SyncEngine: triggerSync() started. Online: \(isOnline), Syncing: \(isSyncing)")
        guard isOnline, !isSyncing, let container = container else { return }
        
        await MainActor.run {
            syncStatusMessage = "Menghubungkan..."
        }
        if !supabase.isAuthenticated {
            do {
                print("SyncEngine: Authenticating anonymous user...")
                try await supabase.signInAnonymously()
                print("SyncEngine: Authentication success. User ID: \(supabase.currentUser?.id.uuidString ?? "nil")")
            } catch {
                print("SyncEngine: Authentication failed: \(error)")
                await MainActor.run {
                    syncStatusMessage = "Koneksi Gagal"
                }
                return
            }
        }

        await MainActor.run {
            isSyncing = true
        }
        defer {
            Task { @MainActor in
                isSyncing = false
            }
        }

        let context = ModelContext(container)
        
        do {
            await MainActor.run {
                syncStatusMessage = "Menyinkronkan Kategori..."
            }
            print("SyncEngine: Starting categories sync...")
            try await syncCategories(context: context)
            
            await MainActor.run {
                syncStatusMessage = "Menyinkronkan Transaksi..."
            }
            print("SyncEngine: Starting transactions sync...")
            try await syncTransactions(context: context)
            
            await MainActor.run {
                syncStatusMessage = "Menyinkronkan Anggaran..."
            }
            print("SyncEngine: Starting budgets sync...")
            try await syncBudgets(context: context)
            
            await MainActor.run {
                syncStatusMessage = "Menyinkronkan Tagihan..."
            }
            print("SyncEngine: Starting bills sync...")
            try await syncBills(context: context)
            
            print("SyncEngine: Sync completed successfully.")
            await MainActor.run {
                syncStatusMessage = "Sinkronisasi Selesai"
                lastSyncedAt = Date()
            }
        } catch {
            print("SyncEngine: Replication sync failed: \(error)")
            await MainActor.run {
                syncStatusMessage = "Cadangan Gagal"
            }
        }
    }

    private func syncCategories(context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        // 1. Upload pending categories
        var fetchDescriptor = FetchDescriptor<Category>()
        fetchDescriptor.predicate = #Predicate<Category> { $0.syncStateValue == "pendingUpload" }
        let pending = try context.fetch(fetchDescriptor)
        print("SyncEngine: Category pending count: \(pending.count)")

        for category in pending {
            print("SyncEngine: Uploading category \(category.name)...")
            let payload = CategorySyncPayload(
                id: category.id.uuidString.lowercased(),
                user_id: userId.uuidString.lowercased(),
                name: category.name,
                icon: category.icon,
                color_hex: category.colorHex,
                is_system: category.isSystem,
                sort_order: category.sortOrder,
                updated_at: ISO8601DateFormatter().string(from: category.updatedAt ?? .now)
            )
            
            if let encoded = try? JSONEncoder().encode(payload) {
                await MainActor.run {
                    totalDataSyncedBytes += Int64(encoded.count)
                    UserDefaults.standard.set(totalDataSyncedBytes, forKey: "total_synced_bytes")
                }
            }

            try await supabase.client
                .from("categories")
                .upsert(payload)
                .execute()
            
            category.syncState = .synced
            print("SyncEngine: Category \(category.name) successfully synced.")
        }
        try? context.save()
    }

    private func syncTransactions(context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        // 1. Upload pending transactions
        var fetchDescriptor = FetchDescriptor<Transaction>()
        fetchDescriptor.predicate = #Predicate<Transaction> { $0.syncStateValue == "pendingUpload" }
        let pending = try context.fetch(fetchDescriptor)
        print("SyncEngine: Transaction pending count: \(pending.count)")

        for transaction in pending {
            print("SyncEngine: Uploading transaction \(transaction.id.uuidString)...")
            if let imageData = transaction.attachmentImageData, transaction.remoteImagePath == nil {
                print("SyncEngine: Uploading attachment image to UploadThing...")
                if let remoteUrl = try? await supabase.uploadImageToUploadThing(imageData: imageData) {
                    transaction.remoteImagePath = remoteUrl
                    print("SyncEngine: Attachment upload successful. URL: \(remoteUrl)")
                    await MainActor.run {
                        totalDataSyncedBytes += Int64(imageData.count)
                    }
                }
            }

            let payload = TransactionSyncPayload(
                id: transaction.id.uuidString.lowercased(),
                user_id: userId.uuidString.lowercased(),
                amount: transaction.amount,
                type: transaction.type.rawValue,
                note: transaction.note,
                date: ISO8601DateFormatter().string(from: transaction.date),
                category_id: transaction.category?.id.uuidString.lowercased(),
                image_path: transaction.remoteImagePath,
                location_latitude: transaction.latitude,
                location_longitude: transaction.longitude,
                updated_at: ISO8601DateFormatter().string(from: transaction.updatedAt ?? .now)
            )

            if let encoded = try? JSONEncoder().encode(payload) {
                await MainActor.run {
                    totalDataSyncedBytes += Int64(encoded.count)
                    UserDefaults.standard.set(totalDataSyncedBytes, forKey: "total_synced_bytes")
                }
            }

            try await supabase.client
                .from("transactions")
                .upsert(payload)
                .execute()

            transaction.syncState = .synced
            print("SyncEngine: Transaction \(transaction.id.uuidString) successfully synced.")
        }
        try? context.save()
    }

    private func syncBudgets(context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        var fetchDescriptor = FetchDescriptor<Budget>()
        fetchDescriptor.predicate = #Predicate<Budget> { $0.syncStateValue == "pendingUpload" }
        let pending = try context.fetch(fetchDescriptor)

        for budget in pending {
            let payload = BudgetSyncPayload(
                id: budget.id.uuidString.lowercased(),
                user_id: userId.uuidString.lowercased(),
                amount: budget.limit,
                category_id: budget.category?.id.uuidString.lowercased(),
                period: budget.period,
                start_date: budget.weekStartDate != nil ? ISO8601DateFormatter().string(from: budget.weekStartDate!) : nil,
                updated_at: ISO8601DateFormatter().string(from: budget.updatedAt ?? .now)
            )

            if let encoded = try? JSONEncoder().encode(payload) {
                await MainActor.run {
                    totalDataSyncedBytes += Int64(encoded.count)
                    UserDefaults.standard.set(totalDataSyncedBytes, forKey: "total_synced_bytes")
                }
            }

            try await supabase.client
                .from("budgets")
                .upsert(payload)
                .execute()

            budget.syncState = .synced
        }
        try? context.save()
    }

    private func syncBills(context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        var fetchDescriptor = FetchDescriptor<Bill>()
        fetchDescriptor.predicate = #Predicate<Bill> { $0.syncStateValue == "pendingUpload" }
        let pending = try context.fetch(fetchDescriptor)

        for bill in pending {
            let payload = BillSyncPayload(
                id: bill.id.uuidString.lowercased(),
                user_id: userId.uuidString.lowercased(),
                title: bill.name,
                amount: bill.amount,
                due_date: ISO8601DateFormatter().string(from: bill.dueDate),
                is_paid: bill.isPaid,
                category_id: bill.category?.id.uuidString.lowercased(),
                updated_at: ISO8601DateFormatter().string(from: bill.updatedAt ?? .now)
            )

            if let encoded = try? JSONEncoder().encode(payload) {
                await MainActor.run {
                    totalDataSyncedBytes += Int64(encoded.count)
                    UserDefaults.standard.set(totalDataSyncedBytes, forKey: "total_synced_bytes")
                }
            }

            try await supabase.client
                .from("bills")
                .upsert(payload)
                .execute()

            bill.syncState = .synced
        }
        try? context.save()
    }

    func clearLocalData(context: ModelContext) {
        do {
            try context.delete(model: Transaction.self)
            try context.delete(model: Category.self)
            try context.delete(model: Budget.self)
            try context.delete(model: Bill.self)
            try context.save()
        } catch {
            print("Failed to clear local SwiftData content: \(error)")
        }
    }
}
