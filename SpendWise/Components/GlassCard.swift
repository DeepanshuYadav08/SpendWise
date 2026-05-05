import SwiftUI

struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    let isPremium: Bool
    @Environment(ThemeManager.self) private var theme
    @ViewBuilder let content: () -> Content
    
    init(cornerRadius: CGFloat = 18, padding: CGFloat = 16, isPremium: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isPremium = isPremium
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(
                ZStack {
                    // Base fill
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(theme.cardBackground.opacity(isPremium ? 0.75 : 0.6))
                    
                    // Material blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(isPremium ? 0.4 : 0.3)
                    
                    // Inner highlight (top edge light reflection)
                    if isPremium {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [theme.primaryText.opacity(0.06), .clear, .clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    }
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: isPremium
                                    ? [theme.accent.opacity(0.3), theme.primaryText.opacity(0.08), theme.accent.opacity(0.15)]
                                    : [theme.primaryText.opacity(0.12), theme.primaryText.opacity(0.04)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: isPremium ? 1.2 : 1
                        )
                }
            )
            .shadow(color: .black.opacity(theme.isDark ? 0.3 : 0.08), radius: isPremium ? 16 : 12, y: isPremium ? 8 : 6)
    }
}
