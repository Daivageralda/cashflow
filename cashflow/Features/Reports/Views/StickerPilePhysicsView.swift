import SwiftUI
import CoreMotion
import Combine

struct StickerObject: Identifiable {
    let id: UUID
    let image: UIImage?
    let iconName: String
    let colorHex: String
    
    var position: CGPoint
    var velocity: CGPoint
    var rotation: Double
}

struct StickerPilePhysicsView: View {
    let transactions: [Transaction]
    var canvasHeight: CGFloat = 480

    @State private var isPhysicsActive: Bool = false
    @State private var stickers: [StickerObject] = []
    @State private var containerSize: CGSize = .zero

    // CoreMotion Manager — same as PhysicsSandboxView
    private let motionManager = CMMotionManager()

    // Render loop timer (ticks every 1/60s) — same as PhysicsSandboxView
    private let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: Spacing.s12) {
            GeometryReader { geo in
                ZStack {
                    // Transparent boundary frame — same pattern as PhysicsSandboxView
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.textSecondary.opacity(0.1), lineWidth: 1)
                        .background(Color.bgSecondary.opacity(0.3))

                    if isPhysicsActive {
                        // Index-based ForEach — avoids Equatable short-circuit that skips position updates
                        ForEach(stickers.indices, id: \.self) { i in
                            if let img = stickers[i].image {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(stickers[i].rotation))
                                    .position(stickers[i].position)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                stickers[i].position = value.location
                                                stickers[i].velocity = .zero
                                            }
                                            .onEnded { value in
                                                stickers[i].velocity = CGPoint(
                                                    x: value.translation.width / 5.0,
                                                    y: value.translation.height / 5.0
                                                )
                                            }
                                    )
                            }
                        }
                    } else {
                        // Centered static pile state — same as PhysicsSandboxView static branch
                        ForEach(stickers) { sticker in
                            if let img = sticker.image {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(Radius.sm)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }

                    if stickers.isEmpty {
                        VStack(spacing: Spacing.s12) {
                            Text("☕️🍕🛍️")
                                .font(.system(size: 40))
                            Text("Belum ada stiker pengeluaran")
                                .font(.cashflowFootnote)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
                .onAppear {
                    containerSize = geo.size
                    loadStickers()
                    startDeviceMotion()
                }
                .onChange(of: geo.size) { _, newSize in
                    containerSize = newSize
                    if !isPhysicsActive {
                        resetToCenter()
                    }
                }
            }
            .frame(height: canvasHeight)
            .clipped()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isPhysicsActive ? "Mode Bebas" : "Mode Diam")
                        .font(.cashflowCaption1)
                        .foregroundStyle(Color.textSecondary)
                    if isPhysicsActive {
                        Text("Miringkan device untuk bermain")
                            .font(.cashflowCaption2)
                            .foregroundStyle(Color.textSecondary.opacity(0.6))
                    }
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isPhysicsActive.toggle()
                        if !isPhysicsActive {
                            // Reset back to center — same as PhysicsSandboxView
                            resetToCenter()
                        }
                    }
                } label: {
                    Text(isPhysicsActive ? "Kunci Objek" : "Lepaskan")
                        .font(.cashflowCaption1)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(isPhysicsActive ? Color.stateCritical : Color.accentPrimary, in: Capsule())
                }
            }
            .padding(.horizontal, Spacing.s4)
        }
        .padding(.bottom, Spacing.s16)
        // Timer at VStack level — same as PhysicsSandboxView
        .onReceive(timer) { _ in
            guard isPhysicsActive else { return }
            updatePhysics()
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    private func loadStickers() {
        let imageTransactions = transactions.filter { $0.attachmentImageData != nil }
        let latestTransactions = imageTransactions.prefix(20)
        var objects: [StickerObject] = []

        let startX = containerSize.width > 0 ? containerSize.width / 2 : 150
        let startY = containerSize.height > 0 ? containerSize.height / 2 : 200

        for (index, tx) in latestTransactions.enumerated() {
            guard let imgData = tx.attachmentImageData, let img = UIImage(data: imgData) else { continue }

            let offset = CGFloat(index * 15)
            let pos = CGPoint(x: startX + CGFloat.random(in: -30...30), y: startY - offset)

            let obj = StickerObject(
                id: UUID(),
                image: img,
                iconName: tx.category?.icon ?? "doc.text",
                colorHex: tx.category?.colorHex ?? "9E9E9E",
                position: pos,
                velocity: .zero,
                rotation: Double.random(in: -20...20)
            )
            objects.append(obj)
        }
        stickers = objects
    }

    private func resetToCenter() {
        let startX = containerSize.width > 0 ? containerSize.width / 2 : 150
        let startY = containerSize.height > 0 ? containerSize.height / 2 : 200
        for i in 0..<stickers.count {
            let offset = CGFloat(i * 15)
            stickers[i].position = CGPoint(x: startX + CGFloat.random(in: -30...30), y: startY - offset)
            stickers[i].velocity = .zero
            stickers[i].rotation = Double(i * 5 - 10)
        }
    }

    private func startDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0/60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard isPhysicsActive, let motion = motion else { return }
            // Translate device tilt (gravity vectors) to sliding velocity adjustments — same as PhysicsSandboxView
            let gravityMultiplier: CGFloat = 0.5
            let gx = CGFloat(motion.gravity.x) * gravityMultiplier
            let gy = -CGFloat(motion.gravity.y) * gravityMultiplier // Invert Y axis for screen space
            for i in 0..<self.stickers.count {
                self.stickers[i].velocity.x += gx
                self.stickers[i].velocity.y += gy
            }
        }
    }

    private func updatePhysics() {
        // Friction coefficient — same as PhysicsSandboxView
        let friction: CGFloat = 0.98
        let halfSize: CGFloat = 50 // Matching half of frame width/height (100x100)

        let minX = halfSize
        let maxX = containerSize.width - halfSize
        let minY = halfSize
        let maxY = containerSize.height - halfSize

        for i in 0..<stickers.count {
            stickers[i].velocity.x *= friction
            stickers[i].velocity.y *= friction

            stickers[i].position.x += stickers[i].velocity.x
            stickers[i].position.y += stickers[i].velocity.y

            // Collisions checks & bounce reaction — same as PhysicsSandboxView
            let restitution: CGFloat = -0.75

            if stickers[i].position.x < minX {
                stickers[i].position.x = minX
                stickers[i].velocity.x *= restitution
            } else if stickers[i].position.x > maxX {
                stickers[i].position.x = maxX
                stickers[i].velocity.x *= restitution
            }

            if stickers[i].position.y < minY {
                stickers[i].position.y = minY
                stickers[i].velocity.y *= restitution
            } else if stickers[i].position.y > maxY {
                stickers[i].position.y = maxY
                stickers[i].velocity.y *= restitution
            }
        }
    }
}
