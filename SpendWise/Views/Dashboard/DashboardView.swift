import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    let txnVM: TransactionViewModel
    let budgetVM: BudgetViewModel
    let insightsVM: InsightsViewModel
    @Binding var selectedTab: Tab
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var profiles: [UserProfile]
    @Environment(ThemeManager.self) private var theme
    @State private var showInsightsSheet = false
    @State private var animateCards = false
    @State private var headerScale: CGFloat = 1.0
    @State private var selectedTransaction: Transaction?
    
    private var profile: UserProfile? { profiles.first }
    private var budget: Double { profile?.monthlyBudget ?? 10000 }
    private var monthlySpent: Double { budgetVM.getMonthlySpent(transactions: transactions) }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                        .staggeredAppear(index: 0, isVisible: animateCards)
                    budgetCard
                        .staggeredAppear(index: 1, isVisible: animateCards)
                    quickStatsRow
                        .staggeredAppear(index: 2, isVisible: animateCards)
                    weeklySparkline
                        .staggeredAppear(index: 3, isVisible: animateCards)
                    insightBanner
                        .staggeredAppear(index: 4, isVisible: animateCards)
                    recentTransactions
                        .staggeredAppear(index: 5, isVisible: animateCards)
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 16)
            }
            .background(theme.background.ignoresSafeArea())
            .onAppear {
                withAnimation(.spring(response: 0.6)) { animateCards = true }
                insightsVM.refreshInsights(transactions: transactions, budget: budget)
            }
            .sheet(item: $selectedTransaction) { txn in
                TransactionDetailView(transaction: txn)
                    .environment(theme)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(profile?.name ?? "User")")
                    .font(.title2.bold())
                    .foregroundStyle(theme.primaryText)
                Text(Date().monthName)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }
            Spacer()
            
            Button { showInsightsSheet = true } label: {
                PremiumIcon("brain.head.profile", size: 18,
                           colors: [theme.accent, theme.accent.opacity(0.7)],
                           glow: theme.accent, style: .filled)
            }
            .bouncePress()
        }
        .padding(.top, 8)
        .sheet(isPresented: $showInsightsSheet) {
            InsightsView(viewModel: insightsVM, transactions: transactions, budget: budget)
                .environment(theme)
        }
    }
    
    // MARK: - Budget Card (tappable → opens insights)
    private var budgetCard: some View {
        Button { showInsightsSheet = true } label: {
            GlassCard(cornerRadius: 24, padding: 20, isPremium: true) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Budget")
                                .font(.subheadline)
                                .foregroundStyle(theme.secondaryText)
                            AnimatedNumber(monthlySpent, font: .system(size: 32, weight: .bold, design: .rounded), color: monthlySpent > budget * 0.8 ? theme.danger : theme.primaryText)
                            Text("of \(budget.currencyFormatted)")
                                .font(.caption)
                                .foregroundStyle(theme.secondaryText)
                        }
                        Spacer()
                        budgetRing
                    }
                    
                    // Budget bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(theme.surface).frame(height: 8)
                            Capsule()
                                .fill(budgetBarGradient)
                                .frame(width: geo.size.width * min(budgetVM.getBudgetProgress(spent: monthlySpent, budget: budget), 1.0), height: 8)
                                .animation(.spring(response: 0.8), value: monthlySpent)
                        }
                    }
                    .frame(height: 8)
                    
                    let status = InsightsEngine.shared.getBudgetStatus(
                        spent: monthlySpent, budget: budget,
                        dayOfMonth: Calendar.current.component(.day, from: Date()),
                        daysInMonth: Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
                    )
                    HStack(spacing: 6) {
                        Circle()
                            .fill(status.isOverspending ? theme.danger : theme.success)
                            .frame(width: 6, height: 6)
                        Text(status.message)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(status.isOverspending ? theme.warning : theme.success)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .bouncePress()
    }
    
    private var budgetRing: some View {
        ZStack {
            Circle()
                .stroke(theme.surface, lineWidth: 6)
                .frame(width: 70, height: 70)
            Circle()
                .trim(from: 0, to: min(budgetVM.getBudgetProgress(spent: monthlySpent, budget: budget), 1.0))
                .stroke(budgetRingColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0), value: monthlySpent)
                .shadow(color: budgetRingColor.opacity(0.4), radius: 6)
            
            Text("\(Int(min(monthlySpent / max(budget, 1) * 100, 100)))%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(theme.primaryText)
        }
    }
    
    private var budgetRingColor: Color {
        let p = monthlySpent / max(budget, 1)
        if p >= 0.9 { return theme.danger }
        if p >= 0.7 { return theme.warning }
        return theme.success
    }
    
    private var budgetBarGradient: LinearGradient {
        let p = monthlySpent / max(budget, 1)
        if p >= 0.9 { return LinearGradient(colors: [theme.danger, theme.danger.opacity(0.7)], startPoint: .leading, endPoint: .trailing) }
        if p >= 0.7 { return LinearGradient(colors: [theme.warning, theme.warning.opacity(0.7)], startPoint: .leading, endPoint: .trailing) }
        return LinearGradient(colors: [theme.success, theme.success.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
    }
    
    // MARK: - Quick Stats (all tappable)
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Today → History tab
            Button {
                withAnimation(.spring(response: 0.35)) { selectedTab = .transactions }
                HapticManager.shared.selection()
            } label: {
                statCard("Today", amount: budgetVM.getTodaySpent(transactions: transactions),
                         icon: "sun.max.fill", colors: [.orange, .yellow])
            }
            .bouncePress()
            
            // This Week → Analytics tab
            Button {
                withAnimation(.spring(response: 0.35)) { selectedTab = .analytics }
                HapticManager.shared.selection()
            } label: {
                statCard("This Week", amount: budgetVM.getWeekSpent(transactions: transactions),
                         icon: "calendar", colors: [theme.accent, theme.accent.opacity(0.7)])
            }
            .bouncePress()
            
            // Streak → Insights sheet
            Button {
                showInsightsSheet = true
                HapticManager.shared.selection()
            } label: {
                statCard("Streak", amount: Double(GamificationService.shared.getStreakDays(transactions: transactions, budget: budget)),
                         icon: "flame.fill", colors: [.orange, .red], isCurrency: false, suffix: " days")
            }
            .bouncePress()
        }
    }
    
    private func statCard(_ title: String, amount: Double, icon: String, colors: [Color], isCurrency: Bool = true, suffix: String = "") -> some View {
        GlassCard(cornerRadius: 16, padding: 12) {
            VStack(spacing: 6) {
                PremiumIcon(icon, size: 10, colors: colors, style: .filled)
                Text(isCurrency ? amount.abbreviated : "\(Int(amount))\(suffix)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryText)
                Text(title)
                    .font(.system(size: 10)).foregroundStyle(theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Weekly Sparkline (tappable → analytics)
    private var weeklySparkline: some View {
        Button {
            withAnimation(.spring(response: 0.35)) { selectedTab = .analytics }
            HapticManager.shared.selection()
        } label: {
            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        PremiumIcon("chart.xyaxis.line", size: 10, colors: [theme.accent, .cyan], style: .filled)
                        Text("Last 7 Days")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                            .foregroundStyle(theme.secondaryText)
                    }
                    
                    let data = AnalyticsViewModel().getChartData(from: transactions)
                    Chart(data.suffix(7)) { point in
                        LineMark(x: .value("Day", point.label), y: .value("Amount", point.amount))
                            .foregroundStyle(theme.accent)
                            .interpolationMethod(.catmullRom)
                        AreaMark(x: .value("Day", point.label), y: .value("Amount", point.amount))
                            .foregroundStyle(LinearGradient(colors: [theme.accent.opacity(0.3), theme.accent.opacity(0.0)], startPoint: .top, endPoint: .bottom))
                            .interpolationMethod(.catmullRom)
                    }
                    .frame(height: 80)
                    .chartYAxis(.hidden)
                    .chartXAxis { AxisMarks { value in AxisValueLabel().foregroundStyle(theme.secondaryText).font(.system(size: 8)) } }
                }
            }
        }
        .bouncePress()
    }
    
    // MARK: - Insight Banner
    private var insightBanner: some View {
        Group {
            if let insight = insightsVM.insights.first {
                Button { showInsightsSheet = true } label: {
                    GlassCard(cornerRadius: 16) {
                        HStack(spacing: 12) {
                            PremiumIcon(
                                insightIcon(for: insight.type),
                                size: 14,
                                colors: insightColors(for: insight.type),
                                style: .filled
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(insight.title)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(theme.primaryText)
                                Text(insight.message)
                                    .font(.caption)
                                    .foregroundStyle(theme.secondaryText)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                }
                .bouncePress()
            }
        }
    }
    
    // MARK: - Recent Transactions
    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PremiumIcon("clock.arrow.circlepath", size: 10, colors: [theme.accent, .cyan], style: .filled)
                Text("Recent")
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35)) { selectedTab = .transactions }
                    HapticManager.shared.selection()
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.caption.bold())
                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(theme.accent)
                }
            }
            
            if transactions.isEmpty {
                GlassCard {
                    HStack(spacing: 12) {
                        PremiumIcon("note.text.badge.plus", size: 14, colors: [.gray, .gray.opacity(0.6)], style: .outlined)
                        Text("No transactions yet. Tap + to add one!")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, txn in
                    Button { selectedTransaction = txn } label: {
                        TransactionRow(transaction: txn)
                    }
                    .bouncePress()
                    .staggeredAppear(index: index + 6, isVisible: animateCards)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func insightIcon(for type: InsightType) -> String {
        switch type {
        case .warning: return "exclamationmark.triangle.fill"
        case .prediction: return "brain.head.profile.fill"
        case .tip: return "lightbulb.max.fill"
        case .health: return "heart.fill"
        case .budget: return "indianrupeesign.circle.fill"
        case .achievement: return "trophy.fill"
        }
    }
    
    private func insightColors(for type: InsightType) -> [Color] {
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
