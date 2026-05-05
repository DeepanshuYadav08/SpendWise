import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isActive = false
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: isActive ? particle.targetY : -50)
                    .rotationEffect(.degrees(isActive ? particle.rotation : 0))
                    .opacity(isActive ? 0 : 1)
            }
        }
        .onAppear {
            particles = (0..<50).map { _ in
                ConfettiParticle(
                    color: colors.randomElement()!,
                    size: CGFloat.random(in: 4...8),
                    x: CGFloat.random(in: -180...180),
                    targetY: CGFloat.random(in: 200...500),
                    rotation: Double.random(in: 360...720)
                )
            }
            withAnimation(.easeOut(duration: 2.0)) { isActive = true }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let x: CGFloat
    let targetY: CGFloat
    let rotation: Double
}

struct ConfettiModifier: ViewModifier {
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            if isShowing {
                ConfettiView()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { isShowing = false }
                    }
            }
        }
    }
}

extension View {
    func confetti(isShowing: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isShowing: isShowing))
    }
}
