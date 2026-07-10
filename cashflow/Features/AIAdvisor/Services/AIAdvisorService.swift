import Foundation
import SwiftData

struct AIMessage: Identifiable, Codable {
    let id: UUID
    let role: String // "user" or "assistant"
    let content: String

    init(id: UUID = UUID(), role: String, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}

@MainActor
final class AIAdvisorService {
    private var apiKey: String {
        AppEnvironment.shared.sumopodApiKey
    }
    private let baseUrl = "https://ai.sumopod.com/v1/chat/completions"
    private let modelName = "gemini/gemini-3.1-flash-lite"

    func getAdvisorResponse(chatHistory: [AIMessage], modelContext: ModelContext) async throws -> String {
        // Fetch context data
        let userName = UserDefaults.standard.string(forKey: "user_name") ?? "User"
        let currency = UserDefaults.standard.string(forKey: "currency_code") ?? "IDR"

        let txDescriptor = FetchDescriptor<Transaction>()
        let transactions = (try? modelContext.fetch(txDescriptor)) ?? []

        let budgetDescriptor = FetchDescriptor<Budget>()
        let budgets = (try? modelContext.fetch(budgetDescriptor)) ?? []

        // Format data for AI context
        let transactionListString = transactions.prefix(20).map { tx in
            "- \(tx.date.formatted(date: .abbreviated, time: .omitted)): \(tx.type == .income ? "Pemasukan" : "Pengeluaran") \(tx.category?.name ?? "Lainnya") sebesar \(tx.amount.formatted(.currency(code: currency))) (Catatan: \(tx.note))"
        }.joined(separator: "\n")

        let budgetListString = budgets.map { b in
            "- Kategori \(b.category?.name ?? "Lainnya"): limit \(b.limit.formatted(.currency(code: currency)))"
        }.joined(separator: "\n")

        let systemInstruction = """
        Kamu adalah AI Advisor Keuangan pribadi bernama Cashflow AI.
        Nama pengguna: \(userName)
        Mata uang aktif: \(currency)

        Berikut adalah data transaksi terbaru pengguna:
        \(transactionListString.isEmpty ? "Tidak ada transaksi tercatat." : transactionListString)

        Berikut adalah data budget aktif pengguna:
        \(budgetListString.isEmpty ? "Tidak ada budget aktif." : budgetListString)

        Berikan nasihat keuangan yang praktis, suportif, ringkas, dan relevan dengan data di atas. Jangan buat jawaban yang terlalu panjang lebar. Usahakan ramah dan sopan.
        """

        // Construct request messages
        var requestMessages = [["role": "system", "content": systemInstruction]]
        for msg in chatHistory {
            requestMessages.append(["role": msg.role, "content": msg.content])
        }

        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": requestMessages
        ]

        guard let url = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? "Maaf, saya tidak dapat memahami permintaan Anda."
    }

    func getReportsInsight(expensesDescription: String) async -> String {
        let systemInstruction = """
        Kamu adalah AI Advisor Keuangan pribadi bernama Cashflow AI.
        Berikan 1 kalimat analisis singkat, solutif, dan tajam berdasarkan ringkasan data pengeluaran bulanan pengguna berikut.
        Jangan gunakan pembuka (seperti "Berdasarkan data..."), langsung ke intinya dan berikan saran aksi nyata.
        """

        let requestMessages = [
            ["role": "system", "content": systemInstruction],
            ["role": "user", "content": expensesDescription]
        ]

        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": requestMessages
        ]

        guard let url = URL(string: baseUrl) else { return "Gagal menganalisis data." }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return "Koneksi internet bermasalah saat memuat insight."
        }

        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let decoded = try? JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded?.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Tidak ada data belanja bulan ini."
    }
}
