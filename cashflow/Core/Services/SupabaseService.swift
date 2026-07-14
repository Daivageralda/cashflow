import Foundation
import Supabase
import Combine

@MainActor
final class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    let client: SupabaseClient
    let supabaseURL: URL

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isSyncing = false

    private init() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let urlString = dict["SUPABASE_URL"] as? String,
              let url = URL(string: urlString),
              let anonKey = dict["SUPABASE_ANON_KEY"] as? String else {
            fatalError("Supabase credentials missing in Secrets.plist")
        }

        self.supabaseURL = url
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
        
        Task {
            await checkCurrentSession()
        }
    }

    func checkCurrentSession() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    func signInAnonymously() async throws {
        let session = try await client.auth.signInAnonymously()
        self.currentUser = session.user
        self.isAuthenticated = true
    }

    func uploadImageToUploadThing(imageData: Data) async throws -> String {
        if !isAuthenticated {
            try await signInAnonymously()
        }
        
        let session = try await client.auth.session
        let token = session.accessToken

        // Minta presigned upload URL ke Supabase Edge Function
        let functionUrl = supabaseURL.appendingPathComponent("functions/v1/uploadthing-handler")
        var request = URLRequest(url: functionUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "action": "upload",
            "fileType": "image/jpeg",
            "fileSize": imageData.count
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "SupabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to request upload authorization from Edge Function"])
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let uploadUrlString = json["uploadUrl"] as? String,
              let uploadUrl = URL(string: uploadUrlString),
              let fileUrl = json["fileUrl"] as? String else {
            throw NSError(domain: "SupabaseService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid presigned URL response"])
        }

        // Upload biner data gambar langsung ke UploadThing presigned URL
        var uploadRequest = URLRequest(url: uploadUrl)
        uploadRequest.httpMethod = "PUT"
        uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        uploadRequest.httpBody = imageData

        let (_, uploadResponse) = try await URLSession.shared.data(for: uploadRequest)
        guard let httpUploadResponse = uploadResponse as? HTTPURLResponse, httpUploadResponse.statusCode == 200 else {
            throw NSError(domain: "SupabaseService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed binary upload to UploadThing"])
        }

        return fileUrl
    }

    func clearCloudData() async throws {
        guard let user = currentUser else { return }
        // RLS cascade delete akan menghapus baris terkait berdasarkan user_id
        try await client
            .from("profiles")
            .delete()
            .eq("id", value: user.id)
            .execute()
    }

    func deleteAccount() async throws {
        try await clearCloudData()
        // Sign out lokal
        try await client.auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
