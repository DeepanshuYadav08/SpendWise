import SwiftUI
import SwiftData

struct AchievementsView: View {
    let transactions: [Transaction]
    let budget: Double
    @Query private var earnedAchievements: [Achievement]
    @Environment(ThemeManager.self) private var theme
    @State private var showConfetti = false
    @State private var animateCards = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Streak Header
                let streak = GamificationService.shared.getStreakDays(transactions: transactions, budget: budget)
                GlassCard(cornerRadius: 20, isPremium: true) {
                    VStack(spacing: 12) {
                        PremiumIcon("flame.fill", size: 24,
                                   colors: [.orange, .red], glow: .orange, style: .filled)
                            .pulsingGlow(color: .orange, radius: 8)
                        
                        Text("\(streak) Day Streak")
                            .font(.title.bold())
                            .foregroundStyle(theme.primaryText)
                        Text("Days staying under your daily budget")
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                        
                        // Animated streak bar
                        HStack(spacing: 3) {
                            ForEach(0..<7, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(i < min(streak, 7)
                                          ? LinearGradient(colors: [theme.accent, theme.accent.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                          : LinearGradient(colors: [theme.surface, theme.surface], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(theme.primaryText.opacity(0.05), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .staggeredAppear(index: 0, isVisible: animateCards)
                
                // Weekly Savings
                let weeklySaved = GamificationService.shared.getWeeklySavings(transactions: transactions, budget: budget)
                if weeklySaved > 0 {
                    GlassCard(cornerRadius: 16) {
                        HStack(spacing: 12) {
                            PremiumIcon("party.popper.fill", size: 14,
                                       colors: [.green, .yellow], style: .filled)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("You saved \(weeklySaved.currencyFormatted) this week!")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(theme.success)
                                Text("Keep going! You're doing amazing!")
                                    .font(.caption)
                                    .foregroundStyle(theme.secondaryText)
                            }
                        }
                    }
                    .staggeredAppear(index: 1, isVisible: animateCards)
                }
                
                // Earned Achievements
                VStack(alignment: .leading, spacing: 12) {
                    PremiumSectionHeader(icon: "trophy.fill", title: "Earned Badges", colors: [.yellow, .orange])
                    
                    if earnedAchievements.isEmpty {
                        GlassCard {
                            HStack(spacing: 12) {
                                PremiumIcon("target", size: 14, colors: [.gray, .gray.opacity(0.6)], style: .outlined)
                                Text("Start tracking expenses to earn badges!")
                                    .font(.subheadline)
                                    .foregroundStyle(theme.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(Array(earnedAchievements.enumerated()), id: \.element.id) { index, achievement in
                                achievementCard(achievement)
                                    .staggeredAppear(index: index + 2, isVisible: animateCards)
                            }
                        }
                    }
                }
                
                // Locked Achievements
                VStack(alignment: .leading, spacing: 12) {
                    PremiumSectionHeader(icon: "lock.fill", title: "Locked", colors: [.gray, .gray.opacity(0.6)])
                    
                    let earnedIds = Set(earnedAchievements.map { $0.templateId })
                    let locked = AchievementTemplate.all.filter { !earnedIds.contains($0.id) }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(locked, id: \.id) { template in
                            lockedCard(template)
                        }
                    }
                }
                
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .confetti(isShowing: $showConfetti)
        .onAppear {
            withAnimation(.spring(response: 0.5)) { animateCards = true }
        }
    }
    
    private func achievementCard(_ achievement: Achievement) -> some View {
        GlassCard(cornerRadius: 16, padding: 14, isPremium: true) {
            VStack(spacing: 8) {
                PremiumIcon(achievementIcon(achievement.templateId), size: 16,
                           colors: achievementColors(achievement.templateId),
                           glow: achievementColors(achievement.templateId).first,
                           style: .filled)
                Text(achievement.title)
                    .font(.caption.bold())
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                Text(achievement.descriptionText)
                    .font(.system(size: 9))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func lockedCard(_ template: AchievementTemplate) -> some View {
        GlassCard(cornerRadius: 16, padding: 14) {
            VStack(spacing: 8) {
                PremiumIcon("lock.fill", size: 14, colors: [.gray, .gray.opacity(0.5)], style: .outlined)
                Text(template.title)
                    .font(.caption.bold())
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
                Text(template.requirement)
                    .font(.system(size: 9))
                    .foregroundStyle(theme.secondaryText.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .opacity(0.6)
        }
    }
    
    // MARK: - Icon Mapping
    private func achievementIcon(_ templateId: String) -> String {
        switch templateId {
        case "first_transaction": return "star.fill"
        case "budget_hero": return "shield.checkered"
        case "savings_master": return "banknote.fill"
        case "streak_7": return "flame.fill"
        case "streak_30": return "bolt.fill"
        case "categorizer": return "square.grid.2x2.fill"
        case "big_spender": return "crown.fill"
        case "health_conscious": return "heart.fill"
        case "analyst": return "chart.bar.fill"
        case "early_bird": return "sunrise.fill"
        case "night_owl": return "moon.stars.fill"
        case "social_spender": return "person.2.fill"
        default: return "medal.fill"
        }
    }
    
    private func achievementColors(_ templateId: String) -> [Color] {
        switch templateId {
        case "first_transaction": return [.blue, .cyan]
        case "budget_hero": return [.green, .mint]
        case "savings_master": return [.yellow, .orange]
        case "streak_7": return [.orange, .red]
        case "streak_30": return [.red, .pink]
        case "categorizer": return [.purple, .indigo]
        case "big_spender": return [.yellow, .orange]
        case "health_conscious": return [.red, .pink]
        case "analyst": return [.blue, .cyan]
        case "early_bird": return [.orange, .yellow]
        case "night_owl": return [.indigo, .purple]
        case "social_spender": return [.teal, .cyan]
        default: return [.gray, .gray]
        }
    }
}
