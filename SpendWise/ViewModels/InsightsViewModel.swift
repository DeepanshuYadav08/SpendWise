import SwiftUI

@Observable
final class InsightsViewModel {
    var insights: [Insight] = []
    var showBudgetAlert = false
    var budgetAlertResponse: Bool?
    
    func refreshInsights(transactions: [Transaction], budget: Double) {
        insights = InsightsEngine.shared.generateInsights(transactions: transactions, budget: budget)
    }
    
    func checkBudgetAlert(spent: Double, budget: Double) {
        let percent = spent / max(budget, 1) * 100
        if percent >= 50 && budgetAlertResponse == nil {
            showBudgetAlert = true
        }
    }
}
