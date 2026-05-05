import SwiftUI

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case year = "Year"
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let label: String
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: CategoryInfo
    let amount: Double
    let percentage: Double
    let count: Int
}

struct MerchantSpending: Identifiable {
    let id = UUID()
    let merchantName: String
    let amount: Double
    let count: Int
    let category: CategoryInfo
}

@Observable
final class AnalyticsViewModel {
    var selectedPeriod: TimePeriod = .month
    var selectedChartDate: Date?
    
    func getChartData(from transactions: [Transaction]) -> [ChartDataPoint] {
        let cal = Calendar.current
        let now = Date()
        let filtered = filterByPeriod(transactions)
        
        switch selectedPeriod {
        case .week:
            return (0..<7).reversed().compactMap { i in
                guard let day = cal.date(byAdding: .day, value: -i, to: now) else { return nil }
                let dayTxns = filtered.filter { cal.isDate($0.date, inSameDayAs: day) }
                let total = dayTxns.reduce(0) { $0 + $1.amount }
                return ChartDataPoint(date: day, amount: total, label: day.dayName)
            }
        case .month:
            return (0..<30).reversed().compactMap { i in
                guard let day = cal.date(byAdding: .day, value: -i, to: now) else { return nil }
                let dayTxns = filtered.filter { cal.isDate($0.date, inSameDayAs: day) }
                let total = dayTxns.reduce(0) { $0 + $1.amount }
                return ChartDataPoint(date: day, amount: total, label: day.shortFormatted)
            }
        case .threeMonths:
            return (0..<12).reversed().compactMap { i in
                guard let weekStart = cal.date(byAdding: .weekOfYear, value: -i, to: now) else { return nil }
                let weekEnd = cal.date(byAdding: .weekOfYear, value: 1, to: weekStart) ?? weekStart
                let weekTxns = filtered.filter { $0.date >= weekStart && $0.date < weekEnd }
                let total = weekTxns.reduce(0) { $0 + $1.amount }
                return ChartDataPoint(date: weekStart, amount: total, label: weekStart.shortFormatted)
            }
        case .year:
            return (0..<12).reversed().compactMap { i in
                guard let monthStart = cal.date(byAdding: .month, value: -i, to: now) else { return nil }
                let comps = cal.dateComponents([.year, .month], from: monthStart)
                guard let start = cal.date(from: comps),
                      let end = cal.date(byAdding: .month, value: 1, to: start) else { return nil }
                let monthTxns = filtered.filter { $0.date >= start && $0.date < end }
                let total = monthTxns.reduce(0) { $0 + $1.amount }
                let f = DateFormatter(); f.dateFormat = "MMM"
                return ChartDataPoint(date: start, amount: total, label: f.string(from: start))
            }
        }
    }
    
    func getCategoryBreakdown(from transactions: [Transaction]) -> [CategorySpending] {
        let filtered = filterByPeriod(transactions)
        let total = filtered.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        
        let grouped = Dictionary(grouping: filtered) { $0.categoryName }
        return grouped.map { (name, txns) in
            let catTotal = txns.reduce(0) { $0 + $1.amount }
            let info = CategoryInfo.all.first { $0.name == name } ?? CategoryInfo.other
            return CategorySpending(category: info, amount: catTotal, percentage: catTotal / total * 100, count: txns.count)
        }.sorted { $0.amount > $1.amount }
    }
    
    func getTopMerchants(from transactions: [Transaction], limit: Int = 5) -> [MerchantSpending] {
        let filtered = filterByPeriod(transactions)
        let grouped = Dictionary(grouping: filtered) { $0.merchantName }
        return grouped.map { (name, txns) in
            let total = txns.reduce(0) { $0 + $1.amount }
            let info = txns.first?.categoryInfo ?? CategoryInfo.other
            return MerchantSpending(merchantName: name, amount: total, count: txns.count, category: info)
        }.sorted { $0.amount > $1.amount }.prefix(limit).map { $0 }
    }
    
    func getTotalSpent(from transactions: [Transaction]) -> Double {
        filterByPeriod(transactions).reduce(0) { $0 + $1.amount }
    }
    
    func getDailyAverage(from transactions: [Transaction]) -> Double {
        let filtered = filterByPeriod(transactions)
        let total = filtered.reduce(0) { $0 + $1.amount }
        let days: Double = switch selectedPeriod {
        case .week: 7
        case .month: 30
        case .threeMonths: 90
        case .year: 365
        }
        return total / max(days, 1)
    }
    
    func getCalendarData(for month: Date, transactions: [Transaction]) -> [Date: Double] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: month)
        guard let start = cal.date(from: comps),
              let end = cal.date(byAdding: .month, value: 1, to: start) else { return [:] }
        
        let monthTxns = transactions.filter { $0.date >= start && $0.date < end }
        var result: [Date: Double] = [:]
        for txn in monthTxns {
            let day = cal.startOfDay(for: txn.date)
            result[day, default: 0] += txn.amount
        }
        return result
    }
    
    private func filterByPeriod(_ transactions: [Transaction]) -> [Transaction] {
        let cal = Calendar.current
        let now = Date()
        let startDate: Date = switch selectedPeriod {
        case .week: cal.date(byAdding: .day, value: -7, to: now)!
        case .month: cal.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths: cal.date(byAdding: .month, value: -3, to: now)!
        case .year: cal.date(byAdding: .year, value: -1, to: now)!
        }
        return transactions.filter { $0.date >= startDate }
    }
}
