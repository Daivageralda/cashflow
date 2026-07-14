import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColorHex: String = "#6C5F8D"

    private let availableIcons = [
        "tag.fill", "cart.fill", "gift.fill", "gamecontroller.fill",
        "heart.fill", "leaf.fill", "house.fill", "briefcase.fill",
        "book.fill", "sparkles", "film.fill", "graduationcap.fill",
        "hammer.fill", "cross.case.fill", "airplane", "cup.and.saucer.fill"
    ]

    private let availableColors = [
        "#C96B2C", "#6B4B2A", "#E89A45", "#7A8B5C", "#5C5A54",
        "#A8492C", "#8A877E", "#5F8D8A", "#6C5F8D", "#8D5F76",
        "#2C7CA8", "#782CA8"
    ]

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detail Kategori") {
                    TextField("Nama Kategori", text: $name)
                        .font(.cashflowBody)
                }

                Section("Pilih Ikon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.s12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? Color.white : Color(hex: selectedColorHex))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        selectedIcon == icon ? Color(hex: selectedColorHex) : Color(hex: selectedColorHex).opacity(0.12),
                                        in: Circle()
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, Spacing.s8)
                }

                Section("Pilih Warna") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.s12) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Button {
                                selectedColorHex = colorHex
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.textPrimary, lineWidth: selectedColorHex == colorHex ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, Spacing.s8)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .navigationTitle("Kategori Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") { save() }
                        .foregroundStyle(canSave ? Color.accentPrimary : Color.textTertiary)
                        .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(Radius.xl)
    }

    private func save() {
        let category = Category(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            colorHex: selectedColorHex,
            isSystem: false,
            sortOrder: 100
        )
        modelContext.insert(category)
        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
