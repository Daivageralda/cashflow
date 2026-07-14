import SwiftUI
import PhotosUI
import SwiftData

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct ReceiptScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isProcessing: Bool = false
    @State private var showPrefilledForm: Bool = false
    @State private var showCamera: Bool = false

    @State private var parsedAmount: Double = 0
    @State private var parsedMerchant: String = ""
    @State private var parsedCategoryName: String = ""

    private let ocrService = OCRService()

    var body: some View {
        NavigationStack {
            VStack {
                if let selectedImage {
                    ZStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(Radius.md)
                            .padding(Spacing.s16)

                        if isProcessing {
                            Color.black.opacity(0.6)
                                .cornerRadius(Radius.md)
                                .padding(Spacing.s16)

                            VStack(spacing: Spacing.s12) {
                                ProgressView()
                                    .tint(Color.white)
                                Text("Membaca Struk dengan AI...")
                                    .font(.cashflowSubheadline)
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "doc.text.viewfinder",
                        title: "Scan Struk Belanja",
                        description: "Ambil foto atau pilih dari galeri untuk mencatat transaksi otomatis menggunakan AI."
                    )
                }

                Spacer()

                VStack(spacing: Spacing.s12) {
                    Button {
                        showCamera = true
                    } label: {
                        HStack(spacing: Spacing.s8) {
                            Image(systemName: "camera.fill")
                            Text("Ambil Foto Struk")
                        }
                        .font(.cashflowBody)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.s16)
                        .background(Color.accentPrimary, in: RoundedRectangle(cornerRadius: Radius.md))
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack(spacing: Spacing.s8) {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Pilih dari Galeri")
                        }
                        .font(.cashflowBody)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.s16)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.md)
                                .stroke(Color.accentPrimary, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.bottom, Spacing.s24)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Scanner Struk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tutup") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            self.selectedImage = image
                            await processImage(image)
                        }
                    }
                }
            }
            .onChange(of: selectedImage) { _, newImage in
                if let newImage, !isProcessing {
                    Task {
                        await processImage(newImage)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage)
            }
            .sheet(isPresented: $showPrefilledForm) {
                AddTransactionView(
                    prefillAmount: parsedAmount,
                    prefillNote: parsedMerchant,
                    prefillCategoryName: parsedCategoryName,
                    onSuccess: {
                        dismiss()
                    }
                )
            }
        }
    }

    private func processImage(_ image: UIImage) async {
        isProcessing = true
        do {
            let text = try await ocrService.recognizeText(from: image)
            let result = try await ocrService.parseReceiptWithAI(rawText: text)

            parsedAmount = result.total
            parsedMerchant = result.merchant
            parsedCategoryName = result.categoryName

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showPrefilledForm = true
        } catch {
            // Handle error, e.g., show default alert
        }
        isProcessing = false
    }
}
