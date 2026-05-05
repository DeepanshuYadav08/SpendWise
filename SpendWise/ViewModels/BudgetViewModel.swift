import SwiftUI

@Observable
final class BudgetViewModel {
    func getMonthlySpent(transactions: [Transaction]) -> Double {
        let cal = Calendar.current
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        return transactions.filter { $0.date >= monthStart }.reduce(0) { $0 + $1.amount }
    }
    
    func getTodaySpent(transactions: [Transaction]) -> Double {
        transactions.filter { $0.isToday }.reduce(0) { $0 + $1.amount }
    }
    
    func getWeekSpent(transactions: [Transaction]) -> Double {
        let cal = Calendar.current
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return transactions.filter { $0.date >= weekStart }.reduce(0) { $0 + $1.amount }
    }
    
    func getBudgetProgress(spent: Double, budget: Double) -> Double {
        min(spent / max(budget, 1), 1.0)
    }
    
    func getRemainingBudget(spent: Double, budget: Double) -> Double {
        max(budget - spent, 0)
    }
    
    func getDaysRemaining() -> Int {
        let cal = Calendar.current
        let now = Date()
        let daysInMonth = cal.range(of: .day, in: .month, for: now)?.count ?? 30
        let currentDay = cal.component(.day, from: now)
        return daysInMonth - currentDay
    }
    
    func getDailyBudgetRemaining(spent: Double, budget: Double) -> Double {
        let remaining = max(budget - spent, 0)
        let daysLeft = max(getDaysRemaining(), 1)
        return remaining / Double(daysLeft)
    }
}
