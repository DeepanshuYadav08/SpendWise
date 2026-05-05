import Foundation

// MARK: - Categorization Result
struct CategorizationResult {
    let category: CategoryInfo
    let confidence: Double // 0.0 to 1.0
    let reason: String
}

// MARK: - Categorization Service
final class CategorizationService: @unchecked Sendable {
    
    static let shared = CategorizationService()
    private init() {}
    
    // MARK: - Categorize Transaction
    
    func categorize(merchantName: String, amount: Double, note: String = "") -> CategorizationResult {
        let searchText = "\(merchantName) \(note)".lowercased()
        
        // First pass: exact keyword matching
        var bestMatch: (category: CategoryInfo, score: Double, reason: String)?
        
        for category in CategoryInfo.all {
            let matchCount = category.keywords.filter { searchText.contains($0) }.count
            if matchCount > 0 {
                let score = Double(matchCount) / Double(max(category.keywords.count, 1))
                if bestMatch == nil || score > bestMatch!.score {
                    bestMatch = (category, min(score * 2, 1.0), "Matched keywords in merchant name")
                }
            }
        }
        
        // Second pass: amount-based pattern detection
        if bestMatch == nil {
            if let amountResult = categorizeByAmount(amount: amount) {
                bestMatch = amountResult
            }
        }
        
        // Default to transfer or other
        if bestMatch == nil {
            bestMatch = (CategoryInfo.other, 0.3, "No specific category detected")
        }
        
        return CategorizationResult(
            category: bestMatch!.category,
            confidence: bestMatch!.score,
            reason: bestMatch!.reason
        )
    }
    
    // MARK: - Amount-Based Detection
    
    private func categorizeByAmount(amount: Double) -> (category: CategoryInfo, score: Double, reason: String)? {
        // Small daily amounts (₹15-35) could be cigarettes/tobacco
        if amount >= 15 && amount <= 35 {
            return (CategoryInfo.cigarettes, 0.4, "Small recurring amount - possible tobacco purchase")
        }
        
        // Common food delivery range
        if amount >= 100 && amount <= 800 {
            return (CategoryInfo.food, 0.3, "Amount range typical for food orders")
        }
        
        // Common cab fare range
        if amount >= 50 && amount <= 500 {
            return (CategoryInfo.travel, 0.2, "Amount range typical for cab rides")
        }
        
        return nil
    }
    
    // MARK: - Pattern Detection
    
    struct SpendingPattern {
        let category: CategoryInfo
        let frequency: Int          // times per period
        let averageAmount: Double
        let totalAmount: Double
        let period: String          // "daily", "weekly", "monthly"
        let isRisk: Bool
        let insight: String
    }
    
    func detectPatterns(in transactions: [Transaction]) -> [SpendingPattern] {
        var patterns: [SpendingPattern] = []
        
        // Group by category
        let grouped = Dictionary(grouping: transactions) { $0.categoryName }
        
        let now = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        
        for (categoryName, txns) in grouped {
            let recentTxns = txns.filter { $0.date >= thirtyDaysAgo }
            guard !recentTxns.isEmpty else { continue }
            
            let category = CategoryInfo.all.first { $0.name == categoryName } ?? CategoryInfo.other
            let total = recentTxns.reduce(0) { $0 + $1.amount }
            let avg = total / Double(recentTxns.count)
            let frequency = recentTxns.count
            
            // Determine period
            let period: String
            let insight: String
            
            if frequency >= 25 {
                period = "daily"
                let monthlyTotal = total
                let yearlyTotal = monthlyTotal * 12
                if category.isRiskCategory {
                    insight = "You're spending ~₹\(Int(avg)) daily on \(category.name.lowercased()). That's ₹\(Int(monthlyTotal))/month and ₹\(Int(yearlyTotal))/year! 😰"
                } else {
                    insight = "You spend about ₹\(Int(avg)) per day on \(category.name.lowercased()). Monthly total: ₹\(Int(monthlyTotal))"
                }
            } else if frequency >= 8 {
                period = "weekly"
                let weeklyAvg = total / 4
                if category.isRiskCategory {
                    insight = "You spend ₹\(Int(weeklyAvg))/week on \(category.name.lowercased()). Consider cutting back! 💪"
                } else {
                    insight = "\(category.name) spending: ~₹\(Int(weeklyAvg))/week across \(frequency) transactions"
                }
            } else {
                period = "monthly"
                insight = "\(category.name) total this month: ₹\(Int(total)) (\(frequency) transactions)"
            }
            
            patterns.append(SpendingPattern(
                category: category,
                frequency: frequency,
                averageAmount: avg,
                totalAmount: total,
                period: period,
                isRisk: category.isRiskCategory,
                insight: insight
            ))
        }
        
        // Sort: risk categories first, then by total amount
        patterns.sort {
            if $0.isRisk != $1.isRisk { return $0.isRisk }
            return $0.totalAmount > $1.totalAmount
        }
        
        return patterns
    }
}
