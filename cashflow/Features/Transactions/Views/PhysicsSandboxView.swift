import SwiftUI
import CoreMotion
import Combine

struct PhysicsSandboxView: View {
    let image: UIImage
    
    @State private var isPhysicsActive: Bool = false
    
    // Physics properties
    @State private var position: CGPoint = .zero
    @State private var velocity: CGPoint = .zero
    @State private var containerSize: CGSize = .zero
    
    // CoreMotion Manager
    private let motionManager = CMMotionManager()
    
    // Render loop timer (ticks every 1/60s)
    private let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: Spacing.s12) {
            GeometryReader { geo in
                ZStack {
                    // Transparent boundary frame
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.textSecondary.opacity(0.1), lineWidth: 1)
                        .background(Color.bgSecondary.opacity(0.3))
                    
                    if isPhysicsActive {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .position(position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        position = value.location
                                        velocity = .zero
                                    }
                                    .onEnded { value in
                                        // Dynamic fling computed from drag translation speed
                                        velocity = CGPoint(
                                            x: value.translation.width / 5.0,
                                            y: value.translation.height / 5.0
                                        )
                                    }
                            )
                    } else {
                        // Centered Static State
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .cornerRadius(Radius.sm)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .onAppear {
                    containerSize = geo.size
                    position = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    startDeviceMotion()
                }
                .onChange(of: geo.size) { _, newSize in
                    containerSize = newSize
                    if !isPhysicsActive {
                        position = CGPoint(x: newSize.width / 2, y: newSize.height / 2)
                    }
                }
            }
            .frame(height: 220)
            .clipped()
            
            HStack {
                Text(isPhysicsActive ? "Mode Bebas" : "Mode Diam")
                    .font(.cashflowCaption1)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isPhysicsActive.toggle()
                        if !isPhysicsActive {
                            // Reset back to center
                            position = CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
                            velocity = .zero
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
        }
        .onReceive(timer) { _ in
            guard isPhysicsActive else { return }
            updatePhysics()
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private func startDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0/60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard isPhysicsActive, let motion = motion else { return }
            // Translate device tilt (gravity vectors) to sliding velocity adjustments
            let gravityMultiplier: CGFloat = 0.5
            velocity.x += CGFloat(motion.gravity.x) * gravityMultiplier
            velocity.y -= CGFloat(motion.gravity.y) * gravityMultiplier // Invert Y axis for screen space
        }
    }
    
    private func updatePhysics() {
        // Friction coefficient
        let friction: CGFloat = 0.98
        velocity.x *= friction
        velocity.y *= friction
        
        // Boundaries definition
        let halfSize: CGFloat = 50 // Matching half of frame width/height (100x100)
        let minX = halfSize
        let maxX = containerSize.width - halfSize
        let minY = halfSize
        let maxY = containerSize.height - halfSize
        
        // Update positions
        position.x += velocity.x
        position.y += velocity.y
        
        // Collisions checks & bounce reaction
        let restitution: CGFloat = -0.75 // Bounce return force
        
        if position.x < minX {
            position.x = minX
            velocity.x *= restitution
        } else if position.x > maxX {
            position.x = maxX
            velocity.x *= restitution
        }
        
        if position.y < minY {
            position.y = minY
            velocity.y *= restitution
        } else if position.y > maxY {
            position.y = maxY
            velocity.y *= restitution
        }
    }
}
