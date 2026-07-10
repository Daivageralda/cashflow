import Observation
import Foundation

enum AuthState: Equatable {
    case idle
    case authenticating
    case failed(message: String)
    case authenticated
}

@Observable
@MainActor
final class AuthViewModel {
    var authState: AuthState = .idle
    var retryCount: Int = 0
    private let maxRetries = 3

    private let service: BiometricAuthService
    private let appState: AppState

    init(service: BiometricAuthService, appState: AppState) {
        self.service = service
        self.appState = appState
    }

    func attemptAuth() async {
        guard retryCount < maxRetries else {
            authState = .failed(message: "Terlalu banyak percobaan. Coba lagi nanti.")
            return
        }

        authState = .authenticating
        let result = await service.authenticate()

        switch result {
        case .success:
            retryCount = 0
            authState = .authenticated
            appState.authenticate()

        case .failure(let error):
            retryCount += 1
            if let message = error.errorDescription {
                authState = .failed(message: message)
            } else {
                authState = .idle
            }
        }
    }

    func resetRetries() {
        retryCount = 0
        authState = .idle
    }
}
