import SwiftUI
import SwiftData

struct InsightsView: View {
    @Bindable var viewModel: InsightsViewModel
    let transactions: [Transaction]
    let budget: Double
    @Environment(ThemeManager.self) private var theme
    @State private var showBudgetAlert = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Prediction Card
                    if let prediction = viewModel.insights.first(where: { $0.type == .prediction }) {
                        GlassCard(cornerRadius: 20, isPremium: true) {
                            VStack(spacing: 12) {
                                HStack {
                                    PremiumIcon("brain.head.profile.fill", size: 14, colors: [.purple, .indigo], glow: .purple, style: .filled)
                                    Text(prediction.title)
                                        .font(.headline)
                                        .foregroundStyle(theme.primaryText)
                                    Spacer()
                                }
                                Text(prediction.message)
                                    .font(.title3.bold())
                                    .foregroundStyle(theme.accent)
                                Text(prediction.detail)
                                    .font(.caption)
                                    .foregroundStyle(theme.secondaryText)
                            }
                        }
                        .staggeredAppear(index: 0, isVisible: animateCards)
                    }
                    
                    // Budget Check Button
                    Button { showBudgetAlert = true } label: {
                        GlassCard(cornerRadius: 16) {
                            HStack(spacing: 12) {
                                PremiumIcon("lightbulb.max.fill", size: 14, colors: [.orange, .yellow], glow: .orange, style: .filled)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Are you spending wisely?")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(theme.primaryText)
                                    Text("Tap to find out")
                                        .font(.caption)
                                        .foregroundStyle(theme.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }
                    .bouncePress()
                    .staggeredAppear(index: 1, isVisible: animateCards)
                    
                    // Health Corner
                    let healthInsights = viewModel.insights.filter { $0.type == .health }
                    if !healthInsights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            PremiumSectionHeader(icon: "heart.text.square.fill", title: "Health Corner", colors: [.red, .pink])
                            ForEach(Array(healthInsights.enumerated()), id: \.element.id) { index, insight in
                                insightCard(insight)
                                    .staggeredAppear(index: index + 2, isVisible: animateCards)
                            }
                        }
                    }
                    
                    // Active Insights
                    let otherInsights = viewModel.insights.filter { $0.type != .prediction && $0.type != .health }
                    if !otherInsights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            PremiumSectionHeader(icon: "sparkle.magnifyingglass", title: "Insights", colors: [theme.accent, .cyan])
                            ForEach(Array(otherInsights.enumerated()), id: \.element.id) { index, insight in
                                insightCard(insight)
                                    .staggeredAppear(index: index + 4, isVisible: animateCards)
                            }
                        }
                    }
                    
                    // Smart Savings Section
                    savingsSection
                        .staggeredAppear(index: 6, isVisible: animateCards)
                    
                    // Achievements quick view
                    achievementsPreview
                        .staggeredAppear(index: 7, isVisible: animateCards)
                    
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.refreshInsights(transactions: transactions, budget: budget)
                withAnimation(.spring(response: 0.5)) { animateCards = true }
            }
            .sheet(isPresented: $showBudgetAlert) {
                BudgetAlertView(transactions: transactions, budget: budget)
                    .environment(theme)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func insightCard(_ insight: Insight) -> some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    PremiumIcon(
                        insightIconName(insight.type),
                        size: 12,
                        colors: insightIconColors(insight.type),
                        style: .filled
                    )
                    Text(insight.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(theme.primaryText)
                    Spacer()
                    if let cat = insight.categoryName {
                        let info = CategoryInfo.all.first { $0.name == cat }
                        if let info = info {
                            Image(systemName: info.icon)
                                .font(.caption)
                                .foregroundStyle(info.color)
                        }
                    }
                }
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.leading)
                if !insight.detail.isEmpty {
                    Text(insight.detail)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText.opacity(0.8))
                }
            }
        }
    }
    
    private var savingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionHeader(icon: "banknote.fill", title: "Smart Savings", colors: [.green, .mint])
            
            let weeklySaved = GamificationService.shared.getWeeklySavings(transactions: transactions, budget: budget)
            
            GlassCard(cornerRadius: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("This Week's Savings")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                        Spacer()
                        PremiumIcon(
                            weeklySaved > 0 ? "party.popper.fill" : "cloud.rain.fill",
                            size: 14,
                            colors: weeklySaved > 0 ? [.green, .yellow] : [.gray, .blue],
                            style: .naked
                        )
                    }
                    Text(weeklySaved.currencyFormatted)
                        .font(.title2.bold())
                        .foregroundStyle(weeklySaved > 0 ? theme.success : theme.danger)
                    Text(weeklySaved > 0 ? "Great job! Keep it up!" : "Let's try to save more next week!")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
    }
    
    private var achievementsPreview: some View {
        NavigationLink(destination: AchievementsView(transactions: transactions, budget: budget)) {
            GlassCard(cornerRadius: 16) {
                HStack(spacing: 12) {
                    PremiumIcon("trophy.fill", size: 14, colors: [.yellow, .orange], glow: .yellow, style: .filled)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievements")
                            .font(.subheadline.bold())
                            .foregroundStyle(theme.primaryText)
                        Text("View your badges and streaks")
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .bouncePress()
    }
    
    // MARK: - Helpers
    private func insightIconName(_ type: InsightType) -> String {
        switch type {
        case .warning: return "exclamationmark.triangle.fill"
        case .prediction: return "brain.head.profile.fill"
        case .tip: return "lightbulb.max.fill"
        case .health: return "heart.fill"
        case .budget: return "indianrupeesign.circle.fill"
        case .achievement: return "trophy.fill"
        }
    }
    
    private func insightIconColors(_ type: InsightType) -> [Color] {
        switch type {
        case .warning: return [theme.danger, .orange]
        case .prediction: return [.purple, .indigo]
        case .tip: return [theme.success, .mint]
        case .health: return [.red, .pink]
        case .budget: return [theme.accent, .cyan]
        case .achievement: return [.yellow, .orange]
        }
    }
}
