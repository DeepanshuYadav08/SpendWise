import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    var currentStep = 0
    var name = ""
    var monthlyBudget: Double = 10000
    var savingGoal: Double = 3000
    var selectedLifestyles: Set<LifestylePreference> = []
    var selectedRiskHabits: Set<RiskHabit> = []
    
    let totalSteps = 4
    
    var progress: Double { Double(currentStep + 1) / Double(totalSteps) }
    var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return monthlyBudget >= 1000
        case 2: return true
        case 3: return true
        default: return true
        }
    }
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { currentStep += 1 }
            HapticManager.shared.light()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { currentStep -= 1 }
            HapticManager.shared.light()
        }
    }
    
    func toggleLifestyle(_ pref: LifestylePreference) {
        if selectedLifestyles.contains(pref) { selectedLifestyles.remove(pref) }
        else { selectedLifestyles.insert(pref) }
        HapticManager.shared.selection()
    }
    
    func toggleRiskHabit(_ habit: RiskHabit) {
        if selectedRiskHabits.contains(habit) { selectedRiskHabits.remove(habit) }
        else { selectedRiskHabits.insert(habit) }
        HapticManager.shared.selection()
    }
    
    func completeOnboarding(context: ModelContext) {
        let profile = UserProfile(
            name: name.isEmpty ? "User" : name,
            monthlyBudget: monthlyBudget,
            savingGoal: savingGoal,
            lifestylePreferences: Array(selectedLifestyles),
            riskHabits: Array(selectedRiskHabits),
            onboardingCompleted: true
        )
        context.insert(profile)
        SampleDataService.shared.loadSampleData(into: context)
        try? context.save()
        HapticManager.shared.success()
    }
}
