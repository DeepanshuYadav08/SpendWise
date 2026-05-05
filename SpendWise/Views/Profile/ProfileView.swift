import SwiftUI
import SwiftData

struct ProfileView: View {
    @Binding var selectedTab: Tab
    @Query private var profiles: [UserProfile]
    @Query private var transactions: [Transaction]
    @Environment(ThemeManager.self) private var theme
    @Environment(\.modelContext) private var context
    @State private var showResetAlert = false
    @State private var editingBudget = false
    @State private var editingUPI = false
    @State private var budgetText = ""
    @State private var upiText = ""
    @State private var animateCards = false
    
    private var profile: UserProfile? { profiles.first }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Avatar with premium ring
                    avatarSection
                        .staggeredAppear(index: 0, isVisible: animateCards)
                    
                    // Quick Stats (all tappable)
                    quickStatsRow
                        .staggeredAppear(index: 1, isVisible: animateCards)
                    
                    // UPI Settings
                    upiSection
                        .staggeredAppear(index: 2, isVisible: animateCards)
                    
                    // Budget Settings
                    budgetSection
                        .staggeredAppear(index: 3, isVisible: animateCards)
                    
                    // Theme Selection
                    themeSection
                        .staggeredAppear(index: 4, isVisible: animateCards)
                    
                    // Data Management
                    dataSection
                        .staggeredAppear(index: 5, isVisible: animateCards)
                    
                    // About
                    aboutSection
                        .staggeredAppear(index: 6, isVisible: animateCards)
                    
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 16)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.spring(response: 0.6)) { animateCards = true }
            }
            .alert("Clear All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    for txn in transactions { context.delete(txn) }
                    try? context.save()
                    HapticManager.shared.heavy()
                }
            } message: {
                Text("This will delete all transactions. This cannot be undone.")
            }
        }
    }
    
    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Animated gradient ring
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [theme.accent, theme.accent.opacity(0.3), theme.accent],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 88, height: 88)
                
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 80, height: 80)
                
                Text(String((profile?.name ?? "U").prefix(1)).uppercased())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            Text(profile?.name ?? "User")
                .font(.title3.bold())
                .foregroundStyle(theme.primaryText)
            
            Text("Member since \(profile?.createdAt.shortFormatted ?? "today")")
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Quick Stats (all tappable)
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Transactions → History tab
            Button {
                withAnimation(.spring(response: 0.35)) { selectedTab = .transactions }
                HapticManager.shared.selection()
            } label: {
                profileStat("Transactions", value: "\(transactions.count)",
                           icon: "chart.bar.doc.horizontal.fill",
                           colors: [.blue, .cyan])
            }
            .bouncePress()
            
            // Budget → toggle budget edit
            Button {
                editingBudget = true
                budgetText = "\(Int(profile?.monthlyBudget ?? 10000))"
                HapticManager.shared.selection()
            } label: {
                profileStat("Budget", value: profile?.budgetFormatted ?? "₹10,000",
                           icon: "indianrupeesign.circle.fill",
                           colors: [.green, .mint])
            }
            .bouncePress()
            
            // Categories → Analytics tab
            Button {
                withAnimation(.spring(response: 0.35)) { selectedTab = .analytics }
                HapticManager.shared.selection()
            } label: {
                profileStat("Categories", value: "\(Set(transactions.map { $0.categoryName }).count)",
                           icon: "square.grid.2x2.fill",
                           colors: [.purple, .indigo])
            }
            .bouncePress()
        }
    }
    
    private func profileStat(_ label: String, value: String, icon: String, colors: [Color]) -> some View {
        GlassCard(cornerRadius: 14, padding: 12) {
            VStack(spacing: 6) {
                PremiumIcon(icon, size: 12, colors: colors, style: .filled)
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.primaryText)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - UPI Section
    private var upiSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    PremiumIcon("indianrupeesign.arrow.circlepath", size: 12, colors: [.purple, .indigo], style: .filled)
                    Text("UPI Settings")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                HStack {
                    Text("UPI ID")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                    Spacer()
                    if editingUPI {
                        TextField("name@bank", text: $upiText)
                            .keyboardType(.emailAddress)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(theme.primaryText)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 160)
                            .autocapitalization(.none)
                        Button("Save") {
                            profile?.upiId = upiText
                            try? context.save()
                            editingUPI = false
                            HapticManager.shared.success()
                        }
                        .font(.caption.bold())
                        .foregroundStyle(theme.accent)
                    } else {
                        let upi = profile?.upiId ?? ""
                        Text(upi.isEmpty ? "Not set" : upi)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(upi.isEmpty ? theme.secondaryText.opacity(0.5) : theme.primaryText)
                        Button {
                            editingUPI = true
                            upiText = profile?.upiId ?? ""
                        } label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(theme.secondaryText.opacity(0.6))
                    Text("Auto-fetch is not available on iOS. Use SMS paste to add transactions.")
                        .font(.caption2)
                        .foregroundStyle(theme.secondaryText.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - Budget Settings
    private var budgetSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    PremiumIcon("slider.horizontal.3", size: 12, colors: [theme.accent, .cyan], style: .filled)
                    Text("Budget Settings")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                HStack {
                    Text("Monthly Budget")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                    Spacer()
                    if editingBudget {
                        TextField("Budget", text: $budgetText)
                            .keyboardType(.numberPad)
                            .font(.subheadline.bold())
                            .foregroundStyle(theme.primaryText)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Button("Save") {
                            if let val = Double(budgetText) {
                                profile?.monthlyBudget = val
                                try? context.save()
                            }
                            editingBudget = false
                            HapticManager.shared.success()
                        }
                        .font(.caption.bold())
                        .foregroundStyle(theme.accent)
                    } else {
                        Text(profile?.budgetFormatted ?? "₹10,000")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(theme.primaryText)
                        Button {
                            editingBudget = true
                            budgetText = "\(Int(profile?.monthlyBudget ?? 10000))"
                        } label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
                
                Divider().overlay(theme.primaryText.opacity(0.06))
                
                HStack {
                    Text("Saving Goal")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                    Spacer()
                    Text(profile?.savingGoalFormatted ?? "₹3,000")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.success)
                }
            }
        }
    }
    
    // MARK: - Theme Selection
    private var themeSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    PremiumIcon("paintpalette.fill", size: 12, colors: [.pink, .purple], style: .filled)
                    Text("Theme")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                HStack(spacing: 10) {
                    ForEach(AppTheme.allCases) { t in
                        Button {
                            withAnimation(.spring(response: 0.3)) { theme.currentTheme = t }
                            profile?.themePreference = t.rawValue
                            try? context.save()
                            HapticManager.shared.medium()
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themePreviewGradient(t))
                                        .frame(width: 50, height: 50)
                                    if theme.currentTheme == t {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.currentTheme == t ? theme.accent : .clear, lineWidth: 2)
                                )
                                .shadow(color: theme.currentTheme == t ? theme.accent.opacity(0.3) : .clear, radius: 6)
                                
                                Text(t.displayName)
                                    .font(.system(size: 10, weight: theme.currentTheme == t ? .bold : .regular))
                                    .foregroundStyle(theme.currentTheme == t ? theme.accent : theme.secondaryText)
                            }
                        }
                        .bouncePress()
                    }
                }
            }
        }
    }
    
    // MARK: - Data Management
    private var dataSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    PremiumIcon("externaldrive.fill", size: 12, colors: [.orange, .yellow], style: .filled)
                    Text("Data")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                Button {
                    SampleDataService.shared.loadSampleData(into: context)
                    HapticManager.shared.success()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(theme.accent)
                        Text("Load Sample Data")
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(theme.secondaryText)
                    }
                }
                
                Divider().overlay(theme.primaryText.opacity(0.06))
                
                Button { showResetAlert = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(theme.danger)
                        Text("Clear All Transactions")
                            .font(.subheadline)
                            .foregroundStyle(theme.danger)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(theme.secondaryText)
                    }
                }
            }
        }
    }
    
    // MARK: - About
    private var aboutSection: some View {
        GlassCard(isPremium: true) {
            VStack(spacing: 8) {
                PremiumIcon("sparkles", size: 16, colors: [theme.accent, .cyan], glow: theme.accent, style: .filled)
                    .padding(.bottom, 4)
                Text("SpendWise")
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
                Text("v2.0.0")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
                Text("Premium Expense Intelligence")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Helpers
    private func themePreviewGradient(_ t: AppTheme) -> LinearGradient {
        switch t {
        case .dark:
            return LinearGradient(colors: [Color(red: 0.15, green: 0.15, blue: 0.18), Color(red: 0.06, green: 0.06, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .light:
            return LinearGradient(colors: [Color.white, Color(red: 0.92, green: 0.92, blue: 0.95)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .neon:
            return LinearGradient(colors: [Color(red: 0.4, green: 0.1, blue: 0.6), Color(red: 0.2, green: 0.05, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .midnight:
            return LinearGradient(colors: [Color(red: 0.15, green: 0.18, blue: 0.4), Color(red: 0.04, green: 0.05, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
