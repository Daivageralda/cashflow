import SwiftUI
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()
    let biometricAuth = BiometricAuthService()

    var sumopodApiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["SUMOPOD_API_KEY"] as? String else {
            return ""
        }
        return key
    }

    private init() {}
}

