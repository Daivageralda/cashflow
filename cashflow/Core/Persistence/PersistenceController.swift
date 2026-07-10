import SwiftData
import Foundation

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init() {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Budget.self,
            Bill.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [config])
            seedSystemCategoriesIfNeeded()
        } catch {
            fatalError("SwiftData ModelContainer init failed: \(error)")
        }
    }

    private func seedSystemCategoriesIfNeeded() {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.isSystem == true })

        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        Category.systemCategories.enumerated().forEach { index, cat in
            let category = Category(
                name: cat.name,
                icon: cat.icon,
                colorHex: cat.colorHex,
                isSystem: true,
                sortOrder: index
            )
            context.insert(category)
        }

        try? context.save()
    }
}
