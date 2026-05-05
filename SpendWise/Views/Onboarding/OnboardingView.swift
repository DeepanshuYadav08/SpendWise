import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var context
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(theme.surface).frame(height: 4)
                        Capsule().fill(theme.accent)
                            .frame(width: geo.size.width * viewModel.progress, height: 4)
                            .animation(.spring(response: 0.5), value: viewModel.progress)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    welcomeStep.tag(0)
                    budgetStep.tag(1)
                    lifestyleStep.tag(2)
                    riskStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentStep)
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 {
                        Button {
                            viewModel.previousStep()
                        } label: {
                            HStack { Image(systemName: "chevron.left"); Text("Back") }
                                .font(.body.weight(.medium))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, 24).padding(.vertical, 14)
                                .background(Capsule().fill(theme.surface))
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if viewModel.currentStep == viewModel.totalSteps - 1 {
                            viewModel.completeOnboarding(context: context)
                        } else {
                            viewModel.nextStep()
                        }
                    } label: {
                        HStack {
                            Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Let's Go!" : "Next")
                            Image(systemName: viewModel.currentStep == viewModel.totalSteps - 1 ? "rocket.fill" : "chevron.right")
                        }
                        .font(.body.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32).padding(.vertical, 14)
                        .background(Capsule().fill(theme.accentGradient))
                        .shadow(color: theme.accent.opacity(0.3), radius: 8, y: 4)
                    }
                    .bouncePress()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Steps
    
    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.1))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(theme.accent.opacity(0.05))
                    .frame(width: 200, height: 200)
                Text("💰")
                    .font(.system(size: 72))
            }
            
            VStack(spacing: 12) {
                Text("SpendWise")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryText)
                
                Text("Your intelligent expense companion")
                    .font(.title3)
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("Track spending • Get insights • Save more")
                    .font(.subheadline)
                    .foregroundStyle(theme.accent)
            }
            
            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("What should we call you?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.secondaryText)
                
                TextField("Your name", text: $viewModel.name)
                    .font(.body)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.primaryText.opacity(0.1)))
                    .foregroundStyle(theme.primaryText)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var budgetStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("💸").font(.system(size: 56))
                Text("Set Your Monthly Budget")
                    .font(.title2.bold())
                    .foregroundStyle(theme.primaryText)
                Text("We'll track your spending against this limit")
                    .font(.subheadline).foregroundStyle(theme.secondaryText)
            }
            
            // Budget Amount
            VStack(spacing: 16) {
                Text(viewModel.monthlyBudget.currencyFormatted)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accent)
                    .contentTransition(.numericText(value: viewModel.monthlyBudget))
                    .animation(.spring, value: viewModel.monthlyBudget)
                
                Slider(value: $viewModel.monthlyBudget, in: 1000...100000, step: 500)
                    .tint(theme.accent)
                    .padding(.horizontal, 8)
                
                HStack {
                    Text("₹1,000").font(.caption).foregroundStyle(theme.secondaryText)
                    Spacer()
                    Text("₹1,00,000").font(.caption).foregroundStyle(theme.secondaryText)
                }
            }
            .padding(.horizontal, 20)
            
            // Saving Goal
            VStack(spacing: 12) {
                Text("🎯 Monthly Saving Goal")
                    .font(.headline).foregroundStyle(theme.primaryText)
                
                Text(viewModel.savingGoal.currencyFormatted)
                    .font(.title.bold())
                    .foregroundStyle(theme.success)
                    .contentTransition(.numericText(value: viewModel.savingGoal))
                    .animation(.spring, value: viewModel.savingGoal)
                
                Slider(value: $viewModel.savingGoal, in: 500...50000, step: 500)
                    .tint(theme.success)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var lifestyleStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("🌟").font(.system(size: 56))
                Text("Your Lifestyle")
                    .font(.title2.bold()).foregroundStyle(theme.primaryText)
                Text("Select what describes you (helps personalize insights)")
                    .font(.subheadline).foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(LifestylePreference.allCases) { pref in
                    let selected = viewModel.selectedLifestyles.contains(pref)
                    Button { viewModel.toggleLifestyle(pref) } label: {
                        HStack(spacing: 8) {
                            Text(pref.emoji)
                            Text(pref.rawValue).font(.subheadline.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selected ? theme.accent.opacity(0.15) : theme.surface)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(selected ? theme.accent : theme.primaryText.opacity(0.08), lineWidth: 1.5))
                        )
                        .foregroundStyle(selected ? theme.accent : theme.primaryText)
                    }
                    .bouncePress()
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var riskStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("🛡️").font(.system(size: 56))
                Text("Habits to Watch")
                    .font(.title2.bold()).foregroundStyle(theme.primaryText)
                Text("Optional — helps us give better health & savings advice")
                    .font(.subheadline).foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(RiskHabit.allCases) { habit in
                    let selected = viewModel.selectedRiskHabits.contains(habit)
                    Button { viewModel.toggleRiskHabit(habit) } label: {
                        HStack(spacing: 12) {
                            Text(habit.emoji).font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.rawValue).font(.body.weight(.medium))
                                Text(habit.warningMessage).font(.caption).foregroundStyle(theme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selected ? theme.accent : theme.secondaryText)
                                .font(.title3)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selected ? theme.accent.opacity(0.1) : theme.surface)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(selected ? theme.accent.opacity(0.3) : theme.primaryText.opacity(0.06), lineWidth: 1))
                        )
                        .foregroundStyle(theme.primaryText)
                    }
                    .bouncePress()
                }
            }
            .padding(.horizontal, 8)
            
            Text("Don't worry, this info stays on your device 🔒")
                .font(.caption).foregroundStyle(theme.secondaryText)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
