import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var transaction: Transaction
    var onDelete: () -> Void

    @State private var isEditing: Bool = false
    @State private var showDeleteConfirm: Bool = false

    @State private var editAmount: String = ""
    @State private var editType: TransactionType = .expense
    @State private var editCategory: Category? = nil
    @State private var editNote: String = ""
    @State private var editDate: Date = .now

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if isEditing {
                        HStack {
                            Text("Rp")
                                .foregroundStyle(Color.textTertiary)
                            TextField("0", text: $editAmount)
                                .keyboardType(.numberPad)
                                .cashflowMonospacedDigits()
                        }
                    } else {
                        HStack {
                            Text("Nominal")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(transaction.amount.formatted(.currency(code: "IDR").presentation(.narrow)))
                                .foregroundStyle(transaction.type == .income ? Color.stateSuccess : Color.textPrimary)
                                .cashflowMonospacedDigits()
                        }
                    }
                }

                Section {
                    if isEditing {
                        Picker("Tipe", selection: $editType) {
                            Text("Pengeluaran").tag(TransactionType.expense)
                            Text("Pemasukan").tag(TransactionType.income)
                        }
                        .pickerStyle(.segmented)
                    } else {
                        HStack {
                            Text("Tipe")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(transaction.type == .income ? "Pemasukan" : "Pengeluaran")
                        }
                    }
                }

                Section("Kategori") {
                    if isEditing {
                        Picker("Kategori", selection: $editCategory) {
                            Text("Pilih kategori").tag(Category?.none)
                            ForEach(categories, id: \.id) { cat in
                                Text(cat.name).tag(cat as Category?)
                            }
                        }
                    } else {
                        HStack {
                            if let cat = transaction.category {
                                Image(systemName: cat.icon)
                                    .foregroundStyle(Color(hex: cat.colorHex))
                                Text(cat.name)
                            } else {
                                Text("Tidak ada kategori").foregroundStyle(Color.textTertiary)
                            }
                        }
                    }
                }

                Section("Catatan") {
                    if isEditing {
                        TextField("Tambahkan catatan...", text: $editNote, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        Text(transaction.note.isEmpty ? "—" : transaction.note)
                            .foregroundStyle(transaction.note.isEmpty ? Color.textTertiary : Color.textPrimary)
                    }
                }

                Section("Tanggal") {
                    if isEditing {
                        DatePicker("", selection: $editDate, displayedComponents: [.date, .hourAndMinute])
                            .tint(Color.accentPrimary)
                    } else {
                        Text(transaction.date.formatted(date: .long, time: .shortened))
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                if !isEditing {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Hapus Transaksi", systemImage: "trash")
                                .foregroundStyle(Color.stateCritical)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .navigationTitle("Detail Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEditing ? "Batal" : "Tutup") {
                        if isEditing { cancelEdit() } else { dismiss() }
                    }
                    .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Simpan" : "Edit") {
                        if isEditing { saveEdit() } else { startEdit() }
                    }
                    .foregroundStyle(Color.accentPrimary)
                }
            }
            .confirmationDialog(
                "Hapus transaksi ini?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Hapus", role: .destructive) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    onDelete()
                    dismiss()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Tindakan ini tidak bisa dibatalkan.")
            }
        }
    }

    private func startEdit() {
        editAmount = String(Int(transaction.amount))
        editType = transaction.type
        editCategory = transaction.category
        editNote = transaction.note
        editDate = transaction.date
        withAnimation { isEditing = true }
    }

    private func cancelEdit() {
        withAnimation { isEditing = false }
    }

    private func saveEdit() {
        let amount = Double(editAmount.filter(\.isNumber)) ?? 0
        guard amount > 0 else { return }

        transaction.amount = amount
        transaction.type = editType
        transaction.category = editCategory
        transaction.note = editNote
        transaction.date = editDate

        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation { isEditing = false }
    }
}
