import Observation
import SwiftData
import Foundation

@Observable
@MainActor
final class AIAdvisorViewModel {
    var messages: [AIMessage] = []
    var isSending: Bool = false
    var inputQuery: String = ""

    private let modelContext: ModelContext
    private let aiService = AIAdvisorService()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Add initial welcome message
        let userName = UserDefaults.standard.string(forKey: "user_name") ?? "User"
        messages.append(
            AIMessage(
                role: "assistant",
                content: "Halo \(userName)! 👋 Saya adalah penasihat keuangan Cashflow AI milikmu. Ada yang ingin kamu tanyakan atau analisis mengenai keuanganmu hari ini?"
            )
        )
    }

    func sendQuery(_ query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMsg = AIMessage(role: "user", content: trimmed)
        messages.append(userMsg)
        inputQuery = ""
        isSending = true

        do {
            let responseText = try await aiService.getAdvisorResponse(chatHistory: messages, modelContext: modelContext)
            let aiMsg = AIMessage(role: "assistant", content: responseText)
            messages.append(aiMsg)
        } catch {
            let errorMsg = AIMessage(
                role: "assistant",
                content: "Maaf, sepertinya terjadi gangguan koneksi internet. Silakan coba kembali nanti."
            )
            messages.append(errorMsg)
        }

        isSending = false
    }

    func clearChat() {
        messages.removeAll()
        let userName = UserDefaults.standard.string(forKey: "user_name") ?? "User"
        messages.append(
            AIMessage(
                role: "assistant",
                content: "Halo \(userName)! 👋 Saya adalah penasihat keuangan Cashflow AI milikmu. Ada yang ingin kamu tanyakan atau analisis mengenai keuanganmu hari ini?"
            )
        )
    }
}
