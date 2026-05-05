import SwiftUI

enum Tab: String, CaseIterable {
    case home, transactions, add, analytics, profile
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .transactions: return "list.bullet.rectangle.fill"
        case .add: return "plus"
        case .analytics: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .transactions: return "History"
        case .add: return "Add"
        case .analytics: return "Analytics"
        case .profile: return "Profile"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddSheet = false
    @State private var txnVM = TransactionViewModel()
    @State private var analyticsVM = AnalyticsViewModel()
    @State private var insightsVM = InsightsViewModel()
    @State private var budgetVM = BudgetViewModel()
    @Environment(ThemeManager.self) private var theme
    @Namespace private var tabAnimation
    @State private var tabBarScale: CGFloat = 1.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .home:
                    DashboardView(txnVM: txnVM, budgetVM: budgetVM, insightsVM: insightsVM, selectedTab: $selectedTab)
                case .transactions:
                    TransactionListView(viewModel: txnVM)
                case .add:
                    Color.clear
                case .analytics:
                    AnalyticsView(viewModel: analyticsVM)
                case .profile:
                    ProfileView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            customTabBar
        }
        .background(theme.background)
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView(viewModel: txnVM)
                .environment(theme)
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .add {
                    // Floating Add Button
                    Button {
                        showAddSheet = true
                        HapticManager.shared.medium()
                        // Bounce animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            tabBarScale = 0.92
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                tabBarScale = 1.0
                            }
                        }
                    } label: {
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(theme.accent.opacity(0.2))
                                .frame(width: 62, height: 62)
                                .blur(radius: 6)
                            
                            Circle()
                                .fill(theme.accentGradient)
                                .frame(width: 52, height: 52)
                                .shadow(color: theme.accent.opacity(0.5), radius: 12, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        }
                        .offset(y: -14)
                        .scaleEffect(tabBarScale)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                        HapticManager.shared.selection()
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                if selectedTab == tab {
                                    Circle()
                                        .fill(theme.accent.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                        .matchedGeometryEffect(id: "tabBG", in: tabAnimation)
                                }
                                
                                Image(systemName: tab.icon)
                                    .font(.system(size: selectedTab == tab ? 18 : 20, weight: selectedTab == tab ? .bold : .regular))
                                    .foregroundStyle(selectedTab == tab ? theme.accent : theme.secondaryText)
                                    .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                            }
                            .frame(height: 36)
                            
                            Text(tab.label)
                                .font(.system(size: 10, weight: selectedTab == tab ? .bold : .regular))
                                .foregroundStyle(selectedTab == tab ? theme.accent : theme.secondaryText)
                            
                            if selectedTab == tab {
                                Capsule()
                                    .fill(theme.accent)
                                    .frame(width: 16, height: 3)
                                    .matchedGeometryEffect(id: "tabIndicator", in: tabAnimation)
                            } else {
                                Capsule()
                                    .fill(.clear)
                                    .frame(width: 16, height: 3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(theme.tabBarBackground)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [theme.primaryText.opacity(0.1), theme.primaryText.opacity(0.03)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: .black.opacity(0.2), radius: 20, y: -8)
            .ignoresSafeArea()
        )
    }
}
