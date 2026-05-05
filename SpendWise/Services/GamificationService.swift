import Foundation
import SwiftData

final class GamificationService: @unchecked Sendable {
    static let shared = GamificationService()
    private init() {}
    
    func checkAchievements(transactions: [Transaction], achievements: [Achievement], budget: Double) -> [AchievementTemplate] {
        let earnedIds = Set(achievements.map { $0.templateId })
        var newAchievements: [AchievementTemplate] = []
        let cal = Calendar.current
        let now = Date()
        
        // First transaction
        if !earnedIds.contains("first_add") && !transactions.isEmpty {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "first_add" }!)
        }
        
        // 10 transactions
        if !earnedIds.contains("ten_transactions") && transactions.count >= 10 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "ten_transactions" }!)
        }
        
        // 50 transactions
        if !earnedIds.contains("fifty_transactions") && transactions.count >= 50 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "fifty_transactions" }!)
        }
        
        // Weekly savings
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let weekTxns = transactions.filter { $0.date >= weekStart }
        let weekSpent = weekTxns.reduce(0) { $0 + $1.amount }
        let weekBudget = budget / 4.3
        let weekSaved = max(weekBudget - weekSpent, 0)
        
        if !earnedIds.contains("save_500") && weekSaved >= 500 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "save_500" }!)
        }
        if !earnedIds.contains("save_1000") && weekSaved >= 1000 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "save_1000" }!)
        }
        
        // Budget streak (days under daily budget)
        let dailyBudget = budget / 30
        var streak = 0
        for i in 0..<30 {
            guard let day = cal.date(byAdding: .day, value: -i, to: now) else { break }
            let dayTxns = transactions.filter { cal.isDate($0.date, inSameDayAs: day) }
            let daySpent = dayTxns.reduce(0) { $0 + $1.amount }
            if daySpent <= dailyBudget { streak += 1 } else { break }
        }
        
        if !earnedIds.contains("streak_3") && streak >= 3 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "streak_3" }!)
        }
        if !earnedIds.contains("streak_7") && streak >= 7 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "streak_7" }!)
        }
        if !earnedIds.contains("streak_30") && streak >= 30 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "streak_30" }!)
        }
        
        // No risk habit days
        var noRiskStreak = 0
        let riskCats = CategoryInfo.riskCategories.map { $0.name }
        for i in 0..<30 {
            guard let day = cal.date(byAdding: .day, value: -i, to: now) else { break }
            let dayTxns = transactions.filter { cal.isDate($0.date, inSameDayAs: day) }
            let hasRisk = dayTxns.contains { riskCats.contains($0.categoryName) }
            if !hasRisk { noRiskStreak += 1 } else { break }
        }
        
        if !earnedIds.contains("no_risk_7") && noRiskStreak >= 7 {
            newAchievements.append(AchievementTemplate.all.first { $0.id == "no_risk_7" }!)
        }
        
        return newAchievements
    }
    
    func getStreakDays(transactions: [Transaction], budget: Double) -> Int {
        let cal = Calendar.current
        let now = Date()
        let dailyBudget = budget / 30
        var streak = 0
        for i in 0..<365 {
            guard let day = cal.date(byAdding: .day, value: -i, to: now) else { break }
            let dayTxns = transactions.filter { cal.isDate($0.date, inSameDayAs: day) }
            let daySpent = dayTxns.reduce(0) { $0 + $1.amount }
            if daySpent <= dailyBudget { streak += 1 } else { break }
        }
        return streak
    }
    
    func getWeeklySavings(transactions: [Transaction], budget: Double) -> Double {
        let cal = Calendar.current
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekTxns = transactions.filter { $0.date >= weekStart }
        let weekSpent = weekTxns.reduce(0) { $0 + $1.amount }
        return max((budget / 4.3) - weekSpent, 0)
    }
}
