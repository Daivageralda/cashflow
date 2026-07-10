import LocalAuthentication
import Foundation

enum AuthError: LocalizedError {
    case biometryUnavailable
    case biometryNotEnrolled
    case userCancelled
    case systemCancel
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .biometryUnavailable:   return "Face ID tidak tersedia di perangkat ini."
        case .biometryNotEnrolled:   return "Face ID belum dikonfigurasi. Gunakan passcode."
        case .userCancelled:         return nil   // silent
        case .systemCancel:          return nil
        case .unknown(let e):        return e.localizedDescription
        }
    }
}

final class BiometricAuthService {
    private let context = LAContext()

    var biometryType: LABiometryType {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    func authenticate(reason: String = "Verifikasi identitasmu untuk mengakses Cashflow.") async -> Result<Void, AuthError> {
        let context = LAContext()
        var policyError: NSError?

        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &policyError)
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        do {
            let success = try await context.evaluatePolicy(policy, localizedReason: reason)
            return success ? .success(()) : .failure(.userCancelled)
        } catch let error as LAError {
            switch error.code {
            case .biometryNotAvailable:    return .failure(.biometryUnavailable)
            case .biometryNotEnrolled:     return .failure(.biometryNotEnrolled)
            case .userCancel, .appCancel:  return .failure(.userCancelled)
            case .systemCancel:            return .failure(.systemCancel)
            default:                       return .failure(.unknown(error))
            }
        } catch {
            return .failure(.unknown(error))
        }
    }
}
