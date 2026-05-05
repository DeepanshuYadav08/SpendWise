import Foundation

// MARK: - Insight Type
enum InsightType: String {
    case warning = "warning"
    case tip = "tip"
    case achievement = "achievement"
    case health = "health"
    case prediction = "prediction"
    case budget = "budget"
    
    var icon: String {
        switch self {
        case .warning: return "exclamationmark.triangle.fill"
        case .tip: return "lightbulb.fill"
        case .achievement: return "trophy.fill"
        case .health: return "heart.fill"
        case .prediction: return "chart.line.uptrend.xyaxis"
        case .budget: return "indianrupeesign.circle.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .warning: return "🚨"
        case .tip: return "💡"
        case .achievement: return "🏆"
        case .health: return "❤️"
        case .prediction: return "🧠"
        case .budget: return "💰"
        }
    }
}

// MARK: - Insight
struct Insight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let detail: String
    let priority: Int // 1 = highest
    let categoryName: String?
    let actionLabel: String?
}

// MARK: - Insights Engine
final class InsightsEngine: @unchecked Sendable {
    static let shared = InsightsEngine()
    private init() {}
    
    func generateInsights(transactions: [Transaction], budget: Double) -> [Insight] {
        var insights: [Insight] = []
        let cal = Calendar.current
        let now = Date()
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let monthTxns = transactions.filter { $0.date >= monthStart }
        let totalSpent = monthTxns.reduce(0) { $0 + $1.amount }
        
        // Budget insights
        let budgetPercent = (totalSpent / max(budget, 1)) * 100
        let dayOfMonth = cal.component(.day, from: now)
        let daysInMonth = cal.range(of: .day, in: .month, for: now)?.count ?? 30
        let expectedPercent = (Double(dayOfMonth) / Double(daysInMonth)) * 100
        
        if budgetPercent > 80 {
            insights.append(Insight(type: .warning, title: "Budget Alert! 😬", message: "You've used \(Int(budgetPercent))% of your monthly budget!", detail: "₹\(Int(totalSpent)) spent out of ₹\(Int(budget)). Only ₹\(Int(max(budget - totalSpent, 0))) remaining for \(daysInMonth - dayOfMonth) days.", priority: 1, categoryName: nil, actionLabel: "View Budget"))
        } else if budgetPercent > expectedPercent * 1.3 {
            insights.append(Insight(type: .budget, title: "Spending Fast 🏃", message: "You're spending faster than usual this month", detail: "At this rate, you'll exceed your budget by day \(Int(Double(daysInMonth) * (budget / totalSpent * Double(dayOfMonth) / Double(daysInMonth)))).", priority: 2, categoryName: nil, actionLabel: nil))
        }
        
        // Category-wise insights
        let grouped = Dictionary(grouping: monthTxns) { $0.categoryName }
        for (cat, txns) in grouped {
            let catTotal = txns.reduce(0) { $0 + $1.amount }
            let info = CategoryInfo.all.first { $0.name == cat } ?? CategoryInfo.other
            
            if info.isRiskCategory {
                let yearly = catTotal * 12
                insights.append(Insight(type: .health, title: "\(info.emoji) \(cat) Alert", message: "You're spending ₹\(Int(catTotal))/month on \(cat.lowercased()).", detail: "That's ₹\(Int(yearly))/year! You could save ₹\(Int(yearly)) by cutting this habit.", priority: 1, categoryName: cat, actionLabel: "View Details"))
            }
            
            if catTotal > budget * 0.3 {
                insights.append(Insight(type: .warning, title: "\(info.emoji) High \(cat) Spending", message: "\(cat) is \(Int(catTotal / totalSpent * 100))% of your total spending", detail: "₹\(Int(catTotal)) on \(cat.lowercased()) this month across \(txns.count) transactions.", priority: 3, categoryName: cat, actionLabel: nil))
            }
        }
        
        // Pattern-based insights
        let patterns = CategorizationService.shared.detectPatterns(in: transactions)
        for pattern in patterns where pattern.isRisk {
            let savingsMonthly = Int(pattern.totalAmount)
            let savingsYearly = savingsMonthly * 12
            insights.append(Insight(type: .tip, title: "Save ₹\(savingsYearly)/year 💰", message: "Cutting \(pattern.category.name.lowercased()) could save you big!", detail: "You spend ~₹\(Int(pattern.averageAmount)) per transaction, \(pattern.frequency) times a month. That adds up to ₹\(savingsMonthly)/month.", priority: 2, categoryName: pattern.category.name, actionLabel: "View Plan"))
        }
        
        // Prediction
        let last30 = transactions.filter { $0.date >= cal.date(byAdding: .day, value: -30, to: now)! }
        let last60to30 = transactions.filter {
            let d = $0.date
            return d >= cal.date(byAdding: .day, value: -60, to: now)! && d < cal.date(byAdding: .day, value: -30, to: now)!
        }
        let recent = last30.reduce(0) { $0 + $1.amount }
        let previous = last60to30.reduce(0) { $0 + $1.amount }
        let predicted = previous > 0 ? (recent + previous) / 2 : recent
        let trend = previous > 0 ? ((recent - previous) / previous * 100) : 0
        
        insights.append(Insight(type: .prediction, title: "Next Month Forecast 🧠", message: "Predicted spending: ₹\(Int(predicted))", detail: trend > 0 ? "Your spending is trending up by \(Int(trend))% compared to last month." : "Your spending is trending down by \(Int(abs(trend)))%. Keep it up! 🎉", priority: 4, categoryName: nil, actionLabel: nil))
        
        // Savings tips
        let topCategory = grouped.max(by: { $0.value.reduce(0) { $0 + $1.amount } < $1.value.reduce(0) { $0 + $1.amount } })
        if let top = topCategory {
            let topTotal = top.value.reduce(0) { $0 + $1.amount }
            insights.append(Insight(type: .tip, title: "Smart Saving Tip 💡", message: "Reduce \(top.key) spending by 20% to save ₹\(Int(topTotal * 0.2))/month", detail: "\(top.key) is your biggest expense category. Small cutbacks can make a big difference!", priority: 5, categoryName: top.key, actionLabel: nil))
        }
        
        insights.sort { $0.priority < $1.priority }
        return insights
    }
    
    func getBudgetStatus(spent: Double, budget: Double, dayOfMonth: Int, daysInMonth: Int) -> (message: String, emoji: String, isOverspending: Bool) {
        let percent = spent / max(budget, 1) * 100
        let expectedPercent = Double(dayOfMonth) / Double(daysInMonth) * 100
        
        if percent >= 100 {
            return ("Budget exceeded! Time to slow down 😅", "🔴", true)
        } else if percent >= 80 {
            return ("Almost at your limit! \(Int(100 - percent))% remaining 😬", "🟠", true)
        } else if percent > expectedPercent * 1.5 {
            return ("Spending a bit fast, aren't we? 😏", "🟡", true)
        } else if percent > expectedPercent {
            return ("Slightly ahead of pace, but manageable 👍", "🟡", false)
        } else {
            return ("Great job! You're on track! 🎉", "🟢", false)
        }
    }
}
