import SwiftUI

/// A premium icon component that replaces cheap emojis with styled SF Symbols.
/// Uses gradient fills, glow effects, and subtle animations for a high-end look.
struct PremiumIcon: View {
    let systemName: String
    let size: CGFloat
    let colors: [Color]
    let glowColor: Color?
    let style: IconStyle
    
    enum IconStyle {
        case filled        // Gradient circle background
        case outlined      // Subtle border circle
        case naked         // Just the icon with gradient
    }
    
    init(_ systemName: String, size: CGFloat = 20, colors: [Color] = [.blue, .cyan], glow: Color? = nil, style: IconStyle = .filled) {
        self.systemName = systemName
        self.size = size
        self.colors = colors
        self.glowColor = glow
        self.style = style
    }
    
    var body: some View {
        ZStack {
            switch style {
            case .filled:
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: size * 1.8, height: size * 1.8)
                
                if let glow = glowColor {
                    Circle()
                        .fill(glow.opacity(0.25))
                        .frame(width: size * 2.2, height: size * 2.2)
                        .blur(radius: 8)
                }
                
                Image(systemName: systemName)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(.white)
                
            case .outlined:
                Circle()
                    .fill(colors.first?.opacity(0.1) ?? .clear)
                    .frame(width: size * 1.8, height: size * 1.8)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(colors: colors.map { $0.opacity(0.4) }, startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
                
                Image(systemName: systemName)
                    .font(.system(size: size, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
            case .naked:
                Image(systemName: systemName)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: (glowColor ?? colors.first ?? .blue).opacity(0.3), radius: 4, y: 2)
            }
        }
    }
}

// MARK: - Section Header with Premium Icon
struct PremiumSectionHeader: View {
    let icon: String
    let title: String
    let colors: [Color]
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        HStack(spacing: 10) {
            PremiumIcon(icon, size: 14, colors: colors, style: .filled)
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(theme.primaryText)
        }
    }
}
