import SwiftUI

/// Professional payment method badge with gradient background and styled icon.
struct PaymentBadge: View {
    let method: PaymentMethod
    let compact: Bool
    
    init(_ method: PaymentMethod, compact: Bool = true) {
        self.method = method
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Image(systemName: method.icon)
                .font(.system(size: compact ? 9 : 12, weight: .semibold))
            
            if !compact {
                Text(method.rawValue)
                    .font(.system(size: 11, weight: .semibold))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, compact ? 6 : 10)
        .padding(.vertical, compact ? 3 : 5)
        .background(
            Capsule()
                .fill(method.gradient)
        )
        .shadow(color: method.color.opacity(0.3), radius: 3, y: 1)
    }
}

/// Full-size payment method card for detail views.
struct PaymentMethodCard: View {
    let method: PaymentMethod
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(method.gradient)
                    .frame(width: 40, height: 40)
                
                Image(systemName: method.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(method.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                Text(method.subtitle)
                    .font(.caption2)
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }
}

// MARK: - PaymentMethod gradient extension
extension PaymentMethod {
    var gradient: LinearGradient {
        switch self {
        case .upi:
            return LinearGradient(
                colors: [Color(red: 0.5, green: 0.2, blue: 0.9), Color(red: 0.7, green: 0.4, blue: 1.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .card:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.4, blue: 0.9), Color(red: 0.3, green: 0.6, blue: 1.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .wallet:
            return LinearGradient(
                colors: [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.7, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .bank:
            return LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.2, green: 0.8, blue: 0.5)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .cash:
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.7, blue: 0.6), Color(red: 0.4, green: 0.9, blue: 0.8)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
    
    var subtitle: String {
        switch self {
        case .upi: return "Unified Payments Interface"
        case .card: return "Credit / Debit Card"
        case .wallet: return "Digital Wallet"
        case .bank: return "NEFT / IMPS / RTGS"
        case .cash: return "Cash Payment"
        }
    }
}
