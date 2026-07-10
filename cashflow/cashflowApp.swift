import SwiftUI
import SwiftData

@main
struct cashflowApp: App {
    @StateObject private var environment = AppEnvironment.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
                .modelContainer(PersistenceController.shared.container)
        }
    }
}


