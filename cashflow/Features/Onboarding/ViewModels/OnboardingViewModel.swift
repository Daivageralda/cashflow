import Observation
import SwiftData
import Foundation

enum SupportedCurrency: String, CaseIterable, Identifiable {
    case idr = "IDR"
    case usd = "USD"
    case sgd = "SGD"
    case myr = "MYR"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .idr: return "Rp"
        case .usd: return "$"
        case .sgd: return "S$"
        case .myr: return "RM"
        }
    }
    var displayName: String {
        switch self {
        case .idr: return "Rupiah (IDR)"
        case .usd: return "US Dollar (USD)"
        case .sgd: return "Singapore Dollar (SGD)"
        case .myr: return "Malaysian Ringgit (MYR)"
        }
    }
}

@Observable
@MainActor
final class OnboardingViewModel {
    var userName: String = ""
    var selectedCurrency: SupportedCurrency = .idr
    var initialBalance: Double = 0
    var currentPage: Int = 0

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var canProceedFromPage1: Bool {
        !userName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var initialBalanceText: String {
        get { initialBalance == 0 ? "" : String(format: "%.0f", initialBalance) }
        set { initialBalance = Double(newValue.filter(\.isNumber)) ?? 0 }
    }

    func completeOnboarding(context: ModelContext) {
        let defaults = UserDefaults.standard
        defaults.set(userName.trimmingCharacters(in: .whitespaces), forKey: "user_name")
        defaults.set(selectedCurrency.rawValue, forKey: "currency_code")
        defaults.set(initialBalance, forKey: "initial_balance")

        if initialBalance > 0 {
            let incomeDesc = FetchDescriptor<Category>(predicate: #Predicate { $0.name == "Pendapatan" })
            if let incomeCategory = try? context.fetch(incomeDesc).first {
                let initialTransaction = Transaction(
                    amount: initialBalance,
                    type: .income,
                    note: "Saldo awal",
                    date: .now,
                    category: incomeCategory
                )
                context.insert(initialTransaction)
                try? context.save()
            }
        }

        appState.completeOnboarding()
    }
}
