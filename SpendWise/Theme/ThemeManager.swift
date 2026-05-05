import SwiftUI

// MARK: - App Theme
enum AppTheme: String, CaseIterable, Identifiable {
    case dark = "dark"
    case light = "light"
    case neon = "neon"
    case midnight = "midnight"
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .neon: return "Neon"
        case .midnight: return "Midnight"
        }
    }
    var emoji: String {
        switch self {
        case .dark: return "🌑"
        case .light: return "☀️"
        case .neon: return "💜"
        case .midnight: return "🌌"
        }
    }
}

// MARK: - Theme Manager
@Observable
final class ThemeManager {
    var currentTheme: AppTheme {
        didSet { UserDefaults.standard.set(currentTheme.rawValue, forKey: "app_theme") }
    }
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "app_theme") ?? "dark"
        self.currentTheme = AppTheme(rawValue: saved) ?? .dark
    }
    
    // MARK: - Colors
    var background: Color {
        switch currentTheme {
        case .dark: return Color(red: 0.06, green: 0.06, blue: 0.08)
        case .light: return Color(red: 0.96, green: 0.96, blue: 0.98)
        case .neon: return Color(red: 0.05, green: 0.02, blue: 0.1)
        case .midnight: return Color(red: 0.04, green: 0.05, blue: 0.15)
        }
    }
    
    var surface: Color {
        switch currentTheme {
        case .dark: return Color(red: 0.12, green: 0.12, blue: 0.15)
        case .light: return Color.white
        case .neon: return Color(red: 0.1, green: 0.05, blue: 0.18)
        case .midnight: return Color(red: 0.08, green: 0.1, blue: 0.22)
        }
    }
    
    var cardBackground: Color {
        switch currentTheme {
        case .dark: return Color(red: 0.15, green: 0.15, blue: 0.18)
        case .light: return Color.white
        case .neon: return Color(red: 0.12, green: 0.06, blue: 0.22)
        case .midnight: return Color(red: 0.1, green: 0.12, blue: 0.28)
        }
    }
    
    var primaryText: Color {
        switch currentTheme {
        case .dark, .neon, .midnight: return .white
        case .light: return Color(red: 0.1, green: 0.1, blue: 0.12)
        }
    }
    
    var secondaryText: Color {
        switch currentTheme {
        case .dark: return Color(red: 0.6, green: 0.6, blue: 0.65)
        case .light: return Color(red: 0.4, green: 0.4, blue: 0.45)
        case .neon: return Color(red: 0.6, green: 0.5, blue: 0.8)
        case .midnight: return Color(red: 0.5, green: 0.55, blue: 0.75)
        }
    }
    
    var accent: Color {
        switch currentTheme {
        case .dark: return Color(red: 0.4, green: 0.7, blue: 1.0)
        case .light: return Color(red: 0.2, green: 0.5, blue: 0.95)
        case .neon: return Color(red: 0.7, green: 0.3, blue: 1.0)
        case .midnight: return Color(red: 0.95, green: 0.75, blue: 0.3)
        }
    }
    
    var accentGradient: LinearGradient {
        switch currentTheme {
        case .dark:
            return LinearGradient(colors: [Color(red: 0.3, green: 0.6, blue: 1.0), Color(red: 0.5, green: 0.8, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .light:
            return LinearGradient(colors: [Color(red: 0.2, green: 0.5, blue: 0.95), Color(red: 0.4, green: 0.6, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .neon:
            return LinearGradient(colors: [Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 1.0, green: 0.3, blue: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .midnight:
            return LinearGradient(colors: [Color(red: 0.95, green: 0.75, blue: 0.3), Color(red: 1.0, green: 0.5, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var danger: Color { Color(red: 1.0, green: 0.35, blue: 0.35) }
    var success: Color { Color(red: 0.3, green: 0.85, blue: 0.5) }
    var warning: Color { Color(red: 1.0, green: 0.75, blue: 0.3) }
    
    var tabBarBackground: Color {
        switch currentTheme {
        case .dark: return Color(red: 0.08, green: 0.08, blue: 0.1).opacity(0.95)
        case .light: return Color.white.opacity(0.95)
        case .neon: return Color(red: 0.06, green: 0.03, blue: 0.12).opacity(0.95)
        case .midnight: return Color(red: 0.05, green: 0.06, blue: 0.18).opacity(0.95)
        }
    }
    
    var isDark: Bool { currentTheme != .light }
    var colorScheme: ColorScheme { currentTheme == .light ? .light : .dark }
}
