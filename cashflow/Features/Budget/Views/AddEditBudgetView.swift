import SwiftUI
import SwiftData

struct AddEditBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let viewModel: BudgetViewModel
    var budget: Budget? = nil   // nil = mode tambah baru

    @State private var limitText: String = ""
    @State private var selectedCategory: Category? = nil
    @State private var selectedPeriod: String = "monthly"
    @State private var weekStartDate: Date = Date.now

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
                Section("Tipe Periode") {
                    Picker("Periode", selection: $selectedPeriod) {
                        Text("Bulanan").tag("monthly")
                        Text("Mingguan").tag("weekly")
                    }
                    .pickerStyle(.segmented)
                    .disabled(isEditMode)

                    if selectedPeriod == "weekly" {
                        DatePicker("Mulai Tanggal", selection: $weekStartDate, displayedComponents: .date)
                            .onChange(of: weekStartDate) { _, newValue in
                                weekStartDate = alignToStartOfWeek(newValue)
                            }
                    }
                }

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
        .presentationDetents([.large])
        .presentationCornerRadius(Radius.xl)
        .onAppear {
            if let budget {
                limitText = String(Int(budget.limit))
                selectedCategory = budget.category
                selectedPeriod = budget.period
                if let wsd = budget.weekStartDate {
                    weekStartDate = wsd
                }
            } else {
                selectedPeriod = viewModel.selectedPeriod
                weekStartDate = alignToStartOfWeek(viewModel.selectedWeekStart)
            }
        }
    }

    private func alignToStartOfWeek(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    private func save() {
        if let budget {
            viewModel.updateBudget(budget, limit: limit)
        } else if let category = selectedCategory {
            viewModel.addBudget(
                limit: limit,
                category: category,
                period: selectedPeriod,
                weekStartDate: selectedPeriod == "weekly" ? weekStartDate : nil
            )
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
