import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userName: String = ""

    var body: some View {
        Form {
            Section("Informasi Profil") {
                HStack {
                    Text("Nama")
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    TextField("Masukkan nama kamu", text: $userName)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .navigationTitle("Edit Profil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Simpan") {
                    let cleanedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cleanedName.isEmpty {
                        UserDefaults.standard.set(cleanedName, forKey: "user_name")
                    }
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(Color.accentPrimary)
            }
        }
        .onAppear {
            userName = UserDefaults.standard.string(forKey: "user_name") ?? ""
        }
    }
}
