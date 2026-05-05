import SwiftUI

// MARK: - Double Extensions
extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        return formatter.string(from: NSNumber(value: self)) ?? "₹\(Int(self))"
    }
    
    var abbreviated: String {
        if self >= 100000 { return "₹\(String(format: "%.1f", self / 100000))L" }
        if self >= 1000 { return "₹\(String(format: "%.1f", self / 1000))K" }
        return "₹\(Int(self))"
    }
}

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    
    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
    }
    
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
    
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isThisWeek: Bool { Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) }
    var isThisMonth: Bool { Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month) }
    
    var shortFormatted: String {
        let f = DateFormatter(); f.dateFormat = "dd MMM"; return f.string(from: self)
    }
    var dayName: String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: self)
    }
    var monthName: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f.string(from: self)
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - View Extensions
extension View {
    func glassBackground(theme: ThemeManager, cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.cardBackground.opacity(0.7))
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(theme.primaryText.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        )
    }
    
    func cardStyle(theme: ThemeManager) -> some View {
        self.padding(16)
            .glassBackground(theme: theme)
    }
    
    func bouncePress() -> some View {
        self.modifier(BouncePressModifier())
    }
    
    /// Staggered appearance animation — each element delays by index * 0.06s
    func staggeredAppear(index: Int, isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 24)
            .scaleEffect(isVisible ? 1 : 0.96)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8)
                .delay(Double(index) * 0.06),
                value: isVisible
            )
    }
    
    
    /// Pulsating glow effect
    func pulsingGlow(color: Color, radius: CGFloat = 12) -> some View {
        self.modifier(PulsingGlowModifier(color: color, radius: radius))
    }
    
    /// Slide-in from edge
    func slideIn(from edge: Edge = .trailing, isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(
                x: isVisible ? 0 : (edge == .leading ? -40 : (edge == .trailing ? 40 : 0)),
                y: isVisible ? 0 : (edge == .top ? -40 : (edge == .bottom ? 40 : 0))
            )
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isVisible)
    }
}

// MARK: - Bounce Press Modifier (enhanced with haptics)
struct BouncePressModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .brightness(isPressed ? -0.02 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { HapticManager.shared.light() }
                        isPressed = true
                    }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Pulsing Glow Modifier
struct PulsingGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    @State private var pulse = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(pulse ? 0.4 : 0.15), radius: pulse ? radius : radius / 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

// MARK: - Animated Gradient Border Modifier
struct AnimatedGradientBorder: ViewModifier {
    let colors: [Color]
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(
                            colors: colors + [colors.first ?? .clear],
                            center: .center,
                            startAngle: .degrees(rotation),
                            endAngle: .degrees(rotation + 360)
                        ),
                        lineWidth: lineWidth
                    )
                    .blur(radius: 1)
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}
