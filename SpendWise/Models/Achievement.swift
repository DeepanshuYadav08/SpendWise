import Foundation
import SwiftData

// MARK: - Achievement Type
enum AchievementType: String, Codable, CaseIterable {
    case saving = "Saving"
    case streak = "Streak"
    case milestone = "Milestone"
    case habit = "Habit"
}

// MARK: - Achievement Template
struct AchievementTemplate: Identifiable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let type: AchievementType
    let requirement: String
    
    static let all: [AchievementTemplate] = [
        // Saving achievements
        AchievementTemplate(id: "save_500", title: "Baby Saver", description: "Saved ₹500 in a week", emoji: "🐣", type: .saving, requirement: "Save ₹500 in one week"),
        AchievementTemplate(id: "save_1000", title: "Smart Saver", description: "Saved ₹1,000 in a week", emoji: "💰", type: .saving, requirement: "Save ₹1,000 in one week"),
        AchievementTemplate(id: "save_5000", title: "Super Saver", description: "Saved ₹5,000 in a month", emoji: "🏆", type: .saving, requirement: "Save ₹5,000 in one month"),
        AchievementTemplate(id: "save_10000", title: "Money Master", description: "Saved ₹10,000 total", emoji: "👑", type: .saving, requirement: "Save ₹10,000 total"),
        
        // Streak achievements
        AchievementTemplate(id: "streak_3", title: "Getting Started", description: "3 days under budget", emoji: "🔥", type: .streak, requirement: "Stay under budget for 3 consecutive days"),
        AchievementTemplate(id: "streak_7", title: "Week Warrior", description: "7 days under budget", emoji: "⚡", type: .streak, requirement: "Stay under budget for 7 consecutive days"),
        AchievementTemplate(id: "streak_30", title: "Month Champion", description: "30 days under budget", emoji: "🌟", type: .streak, requirement: "Stay under budget for 30 consecutive days"),
        
        // Milestone achievements
        AchievementTemplate(id: "first_add", title: "First Step", description: "Added first transaction", emoji: "👣", type: .milestone, requirement: "Add your first transaction"),
        AchievementTemplate(id: "ten_transactions", title: "Tracking Pro", description: "Tracked 10 transactions", emoji: "📊", type: .milestone, requirement: "Track 10 transactions"),
        AchievementTemplate(id: "fifty_transactions", title: "Expense Expert", description: "Tracked 50 transactions", emoji: "🎯", type: .milestone, requirement: "Track 50 transactions"),
        
        // Habit achievements
        AchievementTemplate(id: "no_risk_7", title: "Clean Streak", description: "7 days without risk spending", emoji: "✨", type: .habit, requirement: "No risk category spending for 7 days"),
        AchievementTemplate(id: "budget_month", title: "Budget Boss", description: "Completed a month under budget", emoji: "🎉", type: .habit, requirement: "End a month under your budget limit"),
    ]
}

// MARK: - Achievement Model (Persisted earned achievements)
@Model
final class Achievement {
    var id: UUID
    var templateId: String
    var title: String
    var descriptionText: String
    var emoji: String
    var type: String
    var dateEarned: Date
    
    init(from template: AchievementTemplate) {
        self.id = UUID()
        self.templateId = template.id
        self.title = template.title
        self.descriptionText = template.description
        self.emoji = template.emoji
        self.type = template.type.rawValue
        self.dateEarned = Date()
    }
    
    var achievementType: AchievementType {
        AchievementType(rawValue: type) ?? .milestone
    }
}
