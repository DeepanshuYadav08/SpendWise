import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    let transaction: Transaction
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @Environment(ThemeManager.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var animateCards = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    CategoryIcon(transaction.categoryInfo, size: 72)
                    
                    Text(transaction.merchantName)
                        .font(.title2.bold())
                        .foregroundStyle(theme.primaryText)
                    
                    Text("- \(transaction.formattedAmount)")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.danger)
                    
                    HStack(spacing: 6) {
                        Image(systemName: transaction.categoryInfo.icon)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(transaction.categoryInfo.color)
                        Text(transaction.categoryName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(transaction.categoryInfo.color)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(transaction.categoryInfo.color.opacity(0.15)))
                }
                .padding(.top, 20)
                .staggeredAppear(index: 0, isVisible: animateCards)
                
                // Payment Method Card
                GlassCard(isPremium: true) {
                    HStack {
                        PaymentMethodCard(method: transaction.payment)
                        Spacer()
                        PaymentBadge(transaction.payment, compact: false)
                    }
                }
                .staggeredAppear(index: 1, isVisible: animateCards)
                
                // Metadata
                GlassCard {
                    VStack(spacing: 14) {
                        metadataRow("Date & Time", value: transaction.fullDateTimeFormatted, icon: "calendar", colors: [.blue, .cyan])
                        Divider().overlay(theme.primaryText.opacity(0.06))
                        metadataRow("Category", value: transaction.categoryName, icon: transaction.categoryInfo.icon, colors: [transaction.categoryInfo.color, transaction.categoryInfo.color.opacity(0.6)])
                        if !transaction.upiRefNumber.isEmpty {
                            Divider().overlay(theme.primaryText.opacity(0.06))
                            metadataRow("UPI Reference", value: transaction.upiRefNumber, icon: "number", colors: [.purple, .indigo])
                        }
                        if !transaction.note.isEmpty {
                            Divider().overlay(theme.primaryText.opacity(0.06))
                            metadataRow("Note", value: transaction.note, icon: "note.text", colors: [.orange, .yellow])
                        }
                    }
                }
                .staggeredAppear(index: 2, isVisible: animateCards)
                
                // Category Insight
                let sameCatTxns = allTransactions.filter { $0.categoryName == transaction.categoryName && $0.isThisMonth }
                let catTotal = sameCatTxns.reduce(0) { $0 + $1.amount }
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            PremiumIcon("chart.pie.fill", size: 12, colors: [.blue, .cyan], style: .filled)
                            Text("Category Insight")
                                .font(.subheadline.bold())
                                .foregroundStyle(theme.primaryText)
                        }
                        
                        Text("You've spent \(catTotal.currencyFormatted) on \(transaction.categoryName) this month across \(sameCatTxns.count) transactions.")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                        
                        if transaction.categoryInfo.isRiskCategory {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(theme.warning)
                                Text("This is a risk category. Consider reducing spending here.")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(theme.warning)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(theme.warning.opacity(0.1)))
                        }
                    }
                }
                .staggeredAppear(index: 3, isVisible: animateCards)
                
                // Merchant pattern
                let merchantTxns = allTransactions.filter { $0.merchantName == transaction.merchantName }
                if merchantTxns.count > 1 {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                PremiumIcon("arrow.triangle.2.circlepath", size: 12, colors: [.purple, .indigo], style: .filled)
                                Text("Pattern Detected")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(theme.primaryText)
                            }
                            Text("This is your \(ordinal(merchantTxns.count)) transaction at \(transaction.merchantName).")
                                .font(.subheadline)
                                .foregroundStyle(theme.secondaryText)
                            Text("Total spent here: \(merchantTxns.reduce(0) { $0 + $1.amount }.currencyFormatted)")
                                .font(.caption.bold())
                                .foregroundStyle(theme.accent)
                        }
                    }
                    .staggeredAppear(index: 4, isVisible: animateCards)
                }
                
                // Raw message
                if !transaction.rawMessage.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                PremiumIcon("doc.text.fill", size: 10, colors: [.gray, .gray.opacity(0.6)], style: .outlined)
                                Text("Original Message")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(theme.secondaryText)
                            }
                            Text(transaction.rawMessage)
                                .font(.caption)
                                .foregroundStyle(theme.primaryText.opacity(0.7))
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 8).fill(theme.surface))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .staggeredAppear(index: 5, isVisible: animateCards)
                }
                
                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 16)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.5)) { animateCards = true }
        }
    }
    
    private func metadataRow(_ label: String, value: String, icon: String, colors: [Color]) -> some View {
        HStack {
            PremiumIcon(icon, size: 9, colors: colors, style: .filled)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.primaryText)
        }
    }
    
    private func ordinal(_ n: Int) -> String {
        let suffix: String
        let ones = n % 10, tens = n % 100
        if tens >= 11 && tens <= 13 { suffix = "th" }
        else if ones == 1 { suffix = "st" }
        else if ones == 2 { suffix = "nd" }
        else if ones == 3 { suffix = "rd" }
        else { suffix = "th" }
        return "\(n)\(suffix)"
    }
}
