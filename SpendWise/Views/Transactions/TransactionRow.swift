import SwiftUI
import SwiftData

struct TransactionRow: View {
    let transaction: Transaction
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(transaction.categoryInfo, size: 42)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchantName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: transaction.categoryInfo.icon)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(transaction.categoryInfo.color)
                    Text(transaction.categoryName)
                        .font(.caption)
                        .foregroundStyle(transaction.categoryInfo.color)
                    
                    if transaction.categoryInfo.isRiskCategory {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(theme.warning)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("- \(transaction.formattedAmount)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(theme.danger)
                
                HStack(spacing: 4) {
                    PaymentBadge(transaction.payment, compact: true)
                    Text(transaction.isToday ? transaction.timeFormatted : transaction.timeAgo)
                        .font(.system(size: 9))
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(theme.primaryText.opacity(0.05), lineWidth: 0.5)
                )
        )
    }
}
