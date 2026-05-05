import SwiftUI

struct CalendarHeatmapView: View {
    let transactions: [Transaction]
    @Environment(ThemeManager.self) private var theme
    @State private var currentMonth = Date()
    @State private var selectedDay: Date?
    
    private var calendarData: [Date: Double] {
        AnalyticsViewModel().getCalendarData(for: currentMonth, transactions: transactions)
    }
    
    private var maxSpending: Double {
        calendarData.values.max() ?? 1
    }
    
    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(spacing: 14) {
                // Month Navigation
                HStack {
                    Button { navigateMonth(-1) } label: {
                        Image(systemName: "chevron.left").foregroundStyle(theme.accent)
                    }
                    Spacer()
                    Text(currentMonth.monthName).font(.headline).foregroundStyle(theme.primaryText)
                    Spacer()
                    Button { navigateMonth(1) } label: {
                        Image(systemName: "chevron.right").foregroundStyle(theme.accent)
                    }
                }
                
                // Day Headers
                let days = ["S", "M", "T", "W", "T", "F", "S"]
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        Text(day).font(.caption2.weight(.medium)).foregroundStyle(theme.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar Grid
                let gridDays = getMonthDays()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(gridDays, id: \.self) { day in
                        if let day = day {
                            let spending = calendarData[Calendar.current.startOfDay(for: day)] ?? 0
                            let intensity = spending / max(maxSpending, 1)
                            
                            Button {
                                selectedDay = selectedDay == day ? nil : day
                                HapticManager.shared.light()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(spending > 0 ? intensityColor(intensity) : theme.surface.opacity(0.3))
                                        .frame(height: 32)
                                    
                                    Text("\(Calendar.current.component(.day, from: day))")
                                        .font(.system(size: 11, weight: spending > 0 ? .semibold : .regular))
                                        .foregroundStyle(spending > 0 ? .white : theme.secondaryText)
                                }
                            }
                        } else {
                            Color.clear.frame(height: 32)
                        }
                    }
                }
                
                // Selected Day Detail
                if let day = selectedDay {
                    let spending = calendarData[Calendar.current.startOfDay(for: day)] ?? 0
                    let dayTxns = transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    
                    HStack {
                        Text(day.shortFormatted).font(.caption.weight(.medium)).foregroundStyle(theme.secondaryText)
                        Spacer()
                        Text("\(dayTxns.count) txns").font(.caption).foregroundStyle(theme.secondaryText)
                        Text(spending.currencyFormatted).font(.caption.bold()).foregroundStyle(theme.accent)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(theme.surface))
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Legend
                HStack(spacing: 4) {
                    Text("Less").font(.system(size: 9)).foregroundStyle(theme.secondaryText)
                    ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { val in
                        RoundedRectangle(cornerRadius: 3).fill(intensityColor(val)).frame(width: 12, height: 12)
                    }
                    Text("More").font(.system(size: 9)).foregroundStyle(theme.secondaryText)
                }
            }
        }
    }
    
    private func intensityColor(_ intensity: Double) -> Color {
        let base = theme.accent
        if intensity < 0.25 { return base.opacity(0.2) }
        if intensity < 0.5 { return base.opacity(0.4) }
        if intensity < 0.75 { return base.opacity(0.65) }
        return base
    }
    
    private func navigateMonth(_ offset: Int) {
        withAnimation(.spring(response: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) ?? currentMonth
            selectedDay = nil
        }
    }
    
    private func getMonthDays() -> [Date?] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: currentMonth)
        guard let monthStart = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        
        let firstWeekday = cal.component(.weekday, from: monthStart) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = cal.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
}
