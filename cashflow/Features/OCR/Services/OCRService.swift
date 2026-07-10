import UIKit
import Vision
import SwiftData

struct ScannedReceiptData: Codable {
    let merchant: String
    let total: Double
    let categoryName: String
}

final class OCRService {
    private var apiKey: String {
        get async {
            await MainActor.run {
                AppEnvironment.shared.sumopodApiKey
            }
        }
    }
    private let baseUrl = "https://ai.sumopod.com/v1/chat/completions"
    private let modelName = "gemini/gemini-3.1-flash-lite"

    func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "OCRService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Gagal memproses gambar."])
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func parseReceiptWithAI(rawText: String) async throws -> ScannedReceiptData {
        let systemInstruction = """
        Kamu adalah AI parser struk belanja untuk aplikasi pengatur keuangan.
        Tugasmu adalah menganalisis teks mentah hasil OCR struk belanja berikut dan mengekstrak info:
        1. Nama merchant/toko (merchant).
        2. Total nominal belanja (total) - hilangkan titik/koma desimal, ambil nominal bersihnya.
        3. Estimasi nama kategori pengeluaran yang cocok (categoryName) dari daftar kategori ini: [Makanan, Transportasi, Hiburan, Belanja, Kesehatan, Edukasi, Tagihan, Lainnya].

        Kamu WAJIB membalas HANYA dengan dokumen JSON bersih tanpa penjelasan Markdown apapun seperti berikut:
        {"merchant": "Indomaret", "total": 45000, "categoryName": "Belanja"}
        """

        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": systemInstruction],
                ["role": "user", "content": rawText]
            ]
        ]

        guard let url = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let key = await apiKey
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
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
        let jsonText = decoded.choices.first?.message.content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard let jsonData = jsonText.data(using: .utf8) else {
            throw NSError(domain: "OCRService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Gagal mendecode hasil AI."])
        }

        return try JSONDecoder().decode(ScannedReceiptData.self, from: jsonData)
    }
}
