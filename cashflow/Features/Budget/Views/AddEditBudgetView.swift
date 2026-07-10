import SwiftUI
import SwiftData

struct AddEditBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let viewModel: BudgetViewModel
    var budget: Budget? = nil   // nil = mode tambah baru

    @State private var limitText: String = ""
    @State private var selectedCategory: Category? = nil

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private var availableCategories: [Category] {
        categories.filter { $0.name != "Pendapatan" }
    }

    private var limit: Double {
        Double(limitText.filter(\.isNumber)) ?? 0
    }

    private var isEditMode: Bool {
        budget != nil
    }

    private var canSave: Bool {
        limit > 0 && (selectedCategory != nil || isEditMode)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detail Anggaran") {
                    HStack {
                        Text("Limit Rp")
                            .foregroundStyle(Color.textSecondary)
                        TextField("0", text: $limitText)
                            .keyboardType(.numberPad)
                            .cashflowMonospacedDigits()
                    }
                }

                if !isEditMode {
                    Section("Pilih Kategori") {
                        Picker("Kategori", selection: $selectedCategory) {
                            Text("Pilih kategori").tag(Category?.none)
                            ForEach(availableCategories, id: \.id) { cat in
                                Text(cat.name).tag(cat as Category?)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .navigationTitle(isEditMode ? "Edit Budget" : "Budget Baru")
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
        .presentationDetents([.medium])
        .presentationCornerRadius(Radius.xl)
        .onAppear {
            if let budget {
                limitText = String(Int(budget.limit))
                selectedCategory = budget.category
            }
        }
    }

    private func save() {
        if let budget {
            viewModel.updateBudget(budget, limit: limit)
        } else if let category = selectedCategory {
            viewModel.addBudget(limit: limit, category: category)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
