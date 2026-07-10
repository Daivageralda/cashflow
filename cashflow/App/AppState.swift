import Observation
import Foundation

@Observable
final class AppState {
    var isAuthenticated: Bool = false
    var isFirstLaunch: Bool

    init() {
        self.isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isFirstLaunch = false
    }

    func authenticate() {
        isAuthenticated = true
    }

    func lock() {
        isAuthenticated = false
    }
}
