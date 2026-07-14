import SwiftUI

struct SmartCutoutEditorView: View {
    let originalImage: UIImage
    var onCompletion: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var cutImage: UIImage? = nil
    @State private var isProcessing: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                if isProcessing {
                    VStack(spacing: Spacing.s16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.accentPrimary)
                        Text("Memisahkan objek...")
                            .font(.cashflowSubheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let cutImage {
                    VStack(spacing: Spacing.s20) {
                        Text("Hasil Potongan Objek")
                            .font(.cashflowHeadline)
                            .foregroundStyle(Color.textPrimary)

                        Spacer()

                        Image(uiImage: cutImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .padding()
                            .cornerRadius(Radius.md)

                        Spacer()
                    }
                    .padding(Spacing.s24)
                } else {
                    VStack(spacing: Spacing.s20) {
                        Text("Deteksi dan potong objek utama secara otomatis (seperti gelas minuman, makanan, atau barang) dengan menekan tombol di bawah.")
                            .font(.cashflowBody)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Image(uiImage: originalImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .cornerRadius(Radius.md)
                            .shadow(radius: 4)

                        Spacer()

                        Button {
                            startCutout()
                        } label: {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Mulai Deteksi & Potong Objek")
                            }
                            .font(.cashflowBody)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.s16)
                            .background(Color.accentPrimary, in: RoundedRectangle(cornerRadius: Radius.md))
                        }
                    }
                    .padding(Spacing.s24)
                }
            }
            .navigationTitle("Smart Cutter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if cutImage != nil {
                        Button("Simpan") {
                            if let cutImage {
                                onCompletion(cutImage)
                            }
                            dismiss()
                        }
                        .font(.cashflowBody)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentPrimary)
                    }
                }
            }
        }
    }

    private func startCutout() {
        isProcessing = true
        ImageSubjectCutter.cutForegroundSubject(from: originalImage) { resultImage in
            DispatchQueue.main.async {
                isProcessing = false
                if let resultImage {
                    self.cutImage = resultImage
                }
            }
        }
    }
}

struct CheckeredPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let size: CGFloat = 12
        let stepsX = Int(ceil(rect.width / size))
        let stepsY = Int(ceil(rect.height / size))

        for x in 0..<stepsX {
            for y in 0..<stepsY {
                if (x + y) % 2 == 0 {
                    path.addRect(CGRect(x: CGFloat(x) * size, y: CGFloat(y) * size, width: size, height: size))
                }
            }
        }
        return path
    }
}
