import SwiftUI
import SwiftData

struct BudgetAlertView: View {
    let transactions: [Transaction]
    let budget: Double
    @Environment(ThemeManager.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var responded = false
    @State private var isRich: Bool?
    @State private var animateIcon = false
    
    private var monthlySpent: Double {
        let cal = Calendar.current
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        return transactions.filter { $0.date >= monthStart }.reduce(0) { $0 + $1.amount }
    }
    
    private var budgetPercent: Int { Int(monthlySpent / max(budget, 1) * 100) }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                if !responded {
                    questionView
                } else if let rich = isRich {
                    responseView(isRich: rich)
                }
            }
            .padding(24)
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateIcon ? 1.15 : 1.0)
                
                PremiumIcon("face.smiling.inverse", size: 32,
                           colors: [.orange, .yellow], glow: .orange, style: .filled)
                    .scaleEffect(animateIcon ? 1.05 : 1.0)
            }
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateIcon)
            .onAppear { animateIcon = true }
            
            VStack(spacing: 8) {
                Text("Budget Check!")
                    .font(.title2.bold())
                    .foregroundStyle(theme.primaryText)
                
                Text("You've spent \(monthlySpent.currencyFormatted) out of \(budget.currencyFormatted)")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("That's \(budgetPercent)% of your budget!")
                    .font(.headline)
                    .foregroundStyle(budgetPercent >= 80 ? theme.danger : theme.warning)
            }
            
            Text("Are you rich enough to spend like this?")
                .font(.headline)
                .foregroundStyle(theme.primaryText)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button {
                    withAnimation(.spring) { isRich = true; responded = true }
                    HapticManager.shared.success()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.callout)
                        Text("Yes")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(theme.success))
                    .foregroundStyle(.white)
                }
                .bouncePress()
                
                Button {
                    withAnimation(.spring) { isRich = false; responded = true }
                    HapticManager.shared.warning()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.callout)
                        Text("No")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(theme.danger))
                    .foregroundStyle(.white)
                }
                .bouncePress()
            }
        }
    }
    
    private func responseView(isRich: Bool) -> some View {
        VStack(spacing: 20) {
            PremiumIcon(
                isRich ? "crown.fill" : "figure.strengthtraining.traditional",
                size: 28,
                colors: isRich ? [.yellow, .orange] : [.blue, .cyan],
                glow: isRich ? .yellow : .blue,
                style: .filled
            )
            
            Text(isRich ? "Alright boss, carry on!" : "Let's make a savings plan!")
                .font(.title2.bold())
                .foregroundStyle(theme.primaryText)
                .multilineTextAlignment(.center)
            
            if isRich {
                VStack(spacing: 12) {
                    Text("We respect the hustle")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                    Text("But remember, even the richest people budget!")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    savingTip("frying.pan.fill", "Cook at home 3x/week", "Save ~₹2,400/month", [.orange, .yellow])
                    savingTip("figure.walk", "Walk short distances", "Save ~₹800/month on cabs", [.green, .mint])
                    savingTip("cup.and.saucer.fill", "Make coffee at home", "Save ~₹600/month", [.brown, .orange])
                    
                    let remaining = max(budget - monthlySpent, 0)
                    let daysLeft = Calendar.current.range(of: .day, in: .month, for: Date())!.count - Calendar.current.component(.day, from: Date())
                    
                    if daysLeft > 0 {
                        HStack(spacing: 10) {
                            PremiumIcon("target", size: 10, colors: [theme.accent, .cyan], style: .filled)
                            Text("Daily limit: \((remaining / Double(daysLeft)).currencyFormatted)")
                                .font(.subheadline.bold())
                                .foregroundStyle(theme.accent)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(theme.accent.opacity(0.1)))
                    }
                }
            }
            
            Button { dismiss() } label: {
                Text("Got it!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(theme.accentGradient))
                    .foregroundStyle(.white)
            }
            .bouncePress()
        }
    }
    
    private func savingTip(_ icon: String, _ title: String, _ saving: String, _ colors: [Color]) -> some View {
        HStack(spacing: 12) {
            PremiumIcon(icon, size: 12, colors: colors, style: .filled)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.primaryText)
                Text(saving)
                    .font(.caption)
                    .foregroundStyle(theme.success)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(theme.surface))
    }
}
