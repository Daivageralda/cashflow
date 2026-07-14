import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @State private var showAddCategory = false

    var body: some View {
        List {
            Section("Kategori Kustom (Dibuat Sendiri)") {
                let customCategories = categories.filter { !$0.isSystem }
                if customCategories.isEmpty {
                    Text("Belum ada kategori kustom. Ketuk tombol + di atas untuk menambahkan.")
                        .font(.cashflowFootnote)
                        .foregroundStyle(Color.textTertiary)
                } else {
                    ForEach(customCategories) { category in
                        HStack {
                            categoryRow(category)
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteCustomCategory)
                }
            }

            Section("Kategori Bawaan Sistem") {
                let systemCategories = categories.filter { $0.isSystem }
                ForEach(systemCategories) { category in
                    categoryRow(category)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.bgPrimary)
        .navigationTitle("Kategori Transaksi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentPrimary)
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
    }

    private func categoryRow(_ category: Category) -> some View {
        HStack(spacing: Spacing.s12) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
            }
            Text(category.name)
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textPrimary)
        }
    }

    private func deleteCustomCategory(at offsets: IndexSet) {
        let customCategories = categories.filter { !$0.isSystem }
        for index in offsets {
            let category = customCategories[index]
            modelContext.delete(category)
        }
        try? modelContext.save()
    }
}
