import SwiftUI
import SwiftData

@main
struct SpendWiseApp: App {
    @State private var theme = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(theme)
                .preferredColorScheme(theme.colorScheme)
        }
        .modelContainer(for: [Transaction.self, UserProfile.self, Achievement.self])
    }
}

struct ContentView: View {
    @Query private var profiles: [UserProfile]
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        Group {
            if let profile = profiles.first, profile.onboardingCompleted {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: profiles.first?.onboardingCompleted)
    }
}
