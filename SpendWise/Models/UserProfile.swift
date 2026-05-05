import Foundation
import SwiftData

// MARK: - Lifestyle Preference
enum LifestylePreference: String, Codable, CaseIterable, Identifiable {
    case foodLover = "Food Lover"
    case traveler = "Traveler"
    case techEnthusiast = "Tech Enthusiast"
    case fitness = "Fitness"
    case bookworm = "Bookworm"
    case gamer = "Gamer"
    case fashionista = "Fashionista"
    case minimalist = "Minimalist"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .foodLover: return "🍕"
        case .traveler: return "✈️"
        case .techEnthusiast: return "💻"
        case .fitness: return "💪"
        case .bookworm: return "📖"
        case .gamer: return "🎮"
        case .fashionista: return "👗"
        case .minimalist: return "🧘"
        }
    }
}

// MARK: - Risk Habit
enum RiskHabit: String, Codable, CaseIterable, Identifiable {
    case smoking = "Smoking"
    case fastFood = "Fast Food Addiction"
    case impulseShopping = "Impulse Shopping"
    case lateNightOrdering = "Late Night Ordering"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .smoking: return "🚬"
        case .fastFood: return "🍟"
        case .impulseShopping: return "🛍️"
        case .lateNightOrdering: return "🌙"
        }
    }
    
    var warningMessage: String {
        switch self {
        case .smoking: return "Smoking is harmful to health and wallet"
        case .fastFood: return "Too much fast food affects your health"
        case .impulseShopping: return "Impulse shopping drains savings fast"
        case .lateNightOrdering: return "Late night orders add up quickly"
        }
    }
}

// MARK: - User Profile Model
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var monthlyBudget: Double
    var savingGoal: Double
    var lifestylePreferencesRaw: [String]
    var riskHabitsRaw: [String]
    var onboardingCompleted: Bool
    var themePreference: String
    var notificationsEnabled: Bool
    var dailySummaryEnabled: Bool
    var weeklySummaryEnabled: Bool
    var upiId: String
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String = "",
        monthlyBudget: Double = 10000,
        savingGoal: Double = 3000,
        lifestylePreferences: [LifestylePreference] = [],
        riskHabits: [RiskHabit] = [],
        onboardingCompleted: Bool = false,
        themePreference: String = "dark",
        notificationsEnabled: Bool = true,
        dailySummaryEnabled: Bool = true,
        weeklySummaryEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.monthlyBudget = monthlyBudget
        self.savingGoal = savingGoal
        self.lifestylePreferencesRaw = lifestylePreferences.map { $0.rawValue }
        self.riskHabitsRaw = riskHabits.map { $0.rawValue }
        self.onboardingCompleted = onboardingCompleted
        self.themePreference = themePreference
        self.notificationsEnabled = notificationsEnabled
        self.dailySummaryEnabled = dailySummaryEnabled
        self.weeklySummaryEnabled = weeklySummaryEnabled
        self.upiId = ""
        self.createdAt = Date()
    }
    
    var lifestylePreferences: [LifestylePreference] {
        get { lifestylePreferencesRaw.compactMap { LifestylePreference(rawValue: $0) } }
        set { lifestylePreferencesRaw = newValue.map { $0.rawValue } }
    }
    
    var riskHabits: [RiskHabit] {
        get { riskHabitsRaw.compactMap { RiskHabit(rawValue: $0) } }
        set { riskHabitsRaw = newValue.map { $0.rawValue } }
    }
    
    var budgetFormatted: String {
        monthlyBudget.currencyFormatted
    }
    
    var savingGoalFormatted: String {
        savingGoal.currencyFormatted
    }
}
