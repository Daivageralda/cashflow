import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var amountText: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var selectedCategory: Category? = nil
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var showDatePicker: Bool = false

    var prefillAmount: Double? = nil
    var prefillNote: String? = nil
    var prefillCategoryName: String? = nil

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private var filteredCategories: [Category] {
        transactionType == .income
            ? categories.filter { $0.name == "Pendapatan" || !$0.isSystem }
            : categories.filter { $0.name != "Pendapatan" }
    }

    private var amount: Double {
        Double(amountText.filter(\.isNumber)) ?? 0
    }

    private var canSave: Bool {
        amount > 0 && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.s24) {
                    amountSection
                    typeToggle
                    categorySection
                    dateSection
                    noteSection
                }
                .padding(Spacing.s16)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Catat Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") { save() }
                        .font(.cashflowHeadline)
                        .foregroundStyle(canSave ? Color.accentPrimary : Color.textTertiary)
                        .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xl)
        .onAppear {
            if let prefill = prefillAmount {
                amountText = String(Int(prefill))
            }
            if let prefillNote {
                note = prefillNote
            }
            if let prefillCat = prefillCategoryName {
                selectedCategory = categories.first { $0.name.localizedCaseInsensitiveContains(prefillCat) }
            }
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Nominal")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: Spacing.s8) {
                Text("Rp")
                    .font(.cashflowTitle2)
                    .foregroundStyle(Color.textTertiary)

                TextField("0", text: $amountText)
                    .font(.cashflowTitle1)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.numberPad)
                    .cashflowMonospacedDigits()
                    .onChange(of: amountText) { _, new in
                        let digits = new.filter(\.isNumber)
                        if let num = Int(digits) {
                            amountText = NumberFormatter.localizedString(from: NSNumber(value: num), number: .decimal)
                                .replacingOccurrences(of: ",", with: ".")
                        }
                    }
            }
            .padding(Spacing.s16)
            .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
        }
    }

    private var typeToggle: some View {
        Picker("Tipe", selection: $transactionType) {
            Text("Pengeluaran").tag(TransactionType.expense)
            Text("Pemasukan").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .onChange(of: transactionType) { _, _ in
            selectedCategory = nil
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Kategori")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: Spacing.s12) {
                ForEach(filteredCategories, id: \.id) { category in
                    categoryChip(category)
                }
            }
        }
    }

    private func categoryChip(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        let color = Color(hex: category.colorHex)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        } label: {
            VStack(spacing: Spacing.s4) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white : color)
                }

                Text(category.name)
                    .font(.cashflowCaption2)
                    .foregroundStyle(isSelected ? Color.accentPrimary : Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Tanggal")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            Button {
                withAnimation { showDatePicker.toggle() }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.textSecondary)

                    Text(date.formatted(date: .long, time: .shortened))
                        .font(.cashflowBody)
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                        .font(.cashflowCaption1)
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(Spacing.s16)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
            }
            .buttonStyle(.plain)

            if showDatePicker {
                DatePicker("", selection: $date, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .tint(Color.accentPrimary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Catatan (opsional)")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            TextField("Tambahkan catatan...", text: $note, axis: .vertical)
                .font(.cashflowBody)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3...6)
                .padding(Spacing.s16)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
        }
    }

    private func save() {
        guard let category = selectedCategory, amount > 0 else { return }

        let tx = Transaction(
            amount: amount,
            type: transactionType,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            category: category
        )
        modelContext.insert(tx)
        try? modelContext.save()

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
