import SwiftUI
import SwiftData

struct AddEditBillView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let viewModel: BillsViewModel

    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var dueDay: Int = 1
    @State private var selectedCategory: Category? = nil

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private var availableCategories: [Category] {
        categories.filter { $0.name != "Pendapatan" }
    }

    private var amount: Double {
        Double(amountText.filter(\.isNumber)) ?? 0
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detail Tagihan") {
                    TextField("Nama Tagihan (misal: Wifi, Listrik)", text: $name)
                        .font(.cashflowBody)

                    HStack {
                        Text("Nominal Rp")
                            .foregroundStyle(Color.textSecondary)
                        TextField("0", text: $amountText)
                            .keyboardType(.numberPad)
                            .cashflowMonospacedDigits()
                    }
                }

                Section("Jadwal Bulanan") {
                    Stepper("Tanggal: \(dueDay)", value: $dueDay, in: 1...31)
                }

                Section("Kategori Pembayaran") {
                    Picker("Kategori", selection: $selectedCategory) {
                        Text("Pilih Kategori").tag(Category?.none)
                        ForEach(availableCategories, id: \.id) { cat in
                            Text(cat.name).tag(cat as Category?)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .navigationTitle("Tambah Tagihan")
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
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(Radius.xl)
    }

    private func save() {
        viewModel.addBill(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            dueDay: dueDay,
            category: selectedCategory
        )
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
