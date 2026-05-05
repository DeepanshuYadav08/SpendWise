import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Bindable var viewModel: AnalyticsViewModel
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(ThemeManager.self) private var theme
    @State private var animateCharts = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Period Selector (premium pill style)
                    HStack(spacing: 0) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.selectedPeriod = period
                                }
                                HapticManager.shared.selection()
                            } label: {
                                Text(period.rawValue)
                                    .font(.caption.weight(viewModel.selectedPeriod == period ? .bold : .medium))
                                    .foregroundStyle(viewModel.selectedPeriod == period ? .white : theme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(viewModel.selectedPeriod == period ? theme.accent : .clear)
                                    )
                            }
                        }
                    }
                    .padding(3)
                    .background(Capsule().fill(theme.surface))
                    .staggeredAppear(index: 0, isVisible: animateCharts)
                    
                    // Summary Stats
                    HStack(spacing: 12) {
                        summaryCard("Total Spent", value: viewModel.getTotalSpent(from: transactions).currencyFormatted,
                                   icon: "arrow.down.circle.fill", colors: [theme.danger, .pink])
                        summaryCard("Daily Avg", value: viewModel.getDailyAverage(from: transactions).currencyFormatted,
                                   icon: "chart.line.uptrend.xyaxis", colors: [theme.accent, .cyan])
                    }
                    .staggeredAppear(index: 1, isVisible: animateCharts)
                    
                    // Line Chart
                    spendingChart
                        .staggeredAppear(index: 2, isVisible: animateCharts)
                    
                    // Category Breakdown
                    categoryBreakdown
                        .staggeredAppear(index: 3, isVisible: animateCharts)
                    
                    // Top Merchants
                    topMerchants
                        .staggeredAppear(index: 4, isVisible: animateCharts)
                    
                    // Calendar Heatmap
                    CalendarHeatmapView(transactions: transactions)
                        .staggeredAppear(index: 5, isVisible: animateCharts)
                    
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.spring(response: 0.8).delay(0.1)) { animateCharts = true }
            }
        }
    }
    
    private func summaryCard(_ title: String, value: String, icon: String, colors: [Color]) -> some View {
        GlassCard(cornerRadius: 16, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                PremiumIcon(icon, size: 12, colors: colors, style: .filled)
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(theme.primaryText)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Spending Chart
    private var spendingChart: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    PremiumIcon("chart.xyaxis.line", size: 10, colors: [theme.accent, .cyan], style: .filled)
                    Text("Spending Trend")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                let data = viewModel.getChartData(from: transactions)
                
                Chart(data) { point in
                    LineMark(x: .value("Date", point.date), y: .value("Amount", animateCharts ? point.amount : 0))
                        .foregroundStyle(theme.accent)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                    
                    AreaMark(x: .value("Date", point.date), y: .value("Amount", animateCharts ? point.amount : 0))
                        .foregroundStyle(
                            LinearGradient(colors: [theme.accent.opacity(0.3), theme.accent.opacity(0.0)],
                                         startPoint: .top, endPoint: .bottom)
                        )
                        .interpolationMethod(.catmullRom)
                    
                    if let selected = viewModel.selectedChartDate,
                       Calendar.current.isDate(point.date, inSameDayAs: selected) {
                        PointMark(x: .value("Date", point.date), y: .value("Amount", point.amount))
                            .foregroundStyle(theme.accent)
                            .symbolSize(80)
                        
                        RuleMark(x: .value("Date", point.date))
                            .foregroundStyle(theme.accent.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                }
                .frame(height: 200)
                .chartXSelection(value: $viewModel.selectedChartDate)
                .chartYAxis {
                    AxisMarks(position: .trailing) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(v.abbreviated).font(.system(size: 9)).foregroundStyle(theme.secondaryText)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel().foregroundStyle(theme.secondaryText).font(.system(size: 9))
                    }
                }
                .animation(.spring(response: 0.8), value: animateCharts)
                .animation(.spring(response: 0.3), value: viewModel.selectedPeriod)
                
                // Selected value tooltip
                if let selected = viewModel.selectedChartDate {
                    let data = viewModel.getChartData(from: transactions)
                    if let point = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selected) }) {
                        HStack {
                            Text(point.date.shortFormatted)
                                .font(.caption)
                                .foregroundStyle(theme.secondaryText)
                            Spacer()
                            Text(point.amount.currencyFormatted)
                                .font(.caption.bold())
                                .foregroundStyle(theme.accent)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(theme.surface))
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
    
    // MARK: - Category Breakdown
    private var categoryBreakdown: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    PremiumIcon("chart.pie.fill", size: 10, colors: [.pink, .purple], style: .filled)
                    Text("Category Breakdown")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                let breakdown = viewModel.getCategoryBreakdown(from: transactions)
                
                if !breakdown.isEmpty {
                    // Pie chart
                    Chart(breakdown) { item in
                        SectorMark(angle: .value("Amount", animateCharts ? item.amount : 0), innerRadius: .ratio(0.55), angularInset: 1.5)
                            .foregroundStyle(item.category.color)
                            .cornerRadius(4)
                    }
                    .frame(height: 180)
                    .animation(.spring(response: 1.0), value: animateCharts)
                    
                    // Legend with SF Symbol icons
                    ForEach(breakdown.prefix(6)) { item in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.category.color)
                                .frame(width: 12, height: 12)
                            Image(systemName: item.category.icon)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(item.category.color)
                                .frame(width: 16)
                            Text(item.category.name)
                                .font(.subheadline)
                                .foregroundStyle(theme.primaryText)
                            Spacer()
                            Text(item.amount.currencyFormatted)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(theme.primaryText)
                            Text("\(Int(item.percentage))%")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(theme.secondaryText)
                                .frame(width: 35, alignment: .trailing)
                        }
                    }
                } else {
                    Text("No data for this period")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
    }
    
    // MARK: - Top Merchants
    private var topMerchants: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    PremiumIcon("storefront.fill", size: 10, colors: [.orange, .yellow], style: .filled)
                    Text("Top Merchants")
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                
                let merchants = viewModel.getTopMerchants(from: transactions)
                let maxAmount = merchants.first?.amount ?? 1
                
                ForEach(merchants) { merchant in
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: merchant.category.icon)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(merchant.category.color)
                                .frame(width: 16)
                            Text(merchant.merchantName)
                                .font(.subheadline)
                                .foregroundStyle(theme.primaryText)
                                .lineLimit(1)
                            Spacer()
                            Text(merchant.amount.currencyFormatted)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.primaryText)
                            Text("(\(merchant.count))")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(theme.surface))
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(theme.surface).frame(height: 4)
                                Capsule()
                                    .fill(
                                        LinearGradient(colors: [merchant.category.color, merchant.category.color.opacity(0.5)],
                                                      startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: geo.size.width * (merchant.amount / maxAmount), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
        }
    }
}
