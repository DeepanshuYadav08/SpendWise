import Foundation
import SwiftData
import SwiftUI

// MARK: - Payment Method Enum
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case upi = "UPI"
    case card = "Card"
    case wallet = "Wallet"
    case bank = "Bank Transfer"
    case cash = "Cash"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .upi: return "indianrupeesign.circle.fill"
        case .card: return "creditcard.fill"
        case .wallet: return "wallet.pass.fill"
        case .bank: return "building.columns.fill"
        case .cash: return "banknote.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .upi: return .purple
        case .card: return .blue
        case .wallet: return .orange
        case .bank: return .green
        case .cash: return .mint
        }
    }
}

// MARK: - Transaction Model
@Model
final class Transaction {
    var id: UUID
    var merchantName: String
    var amount: Double
    var date: Date
    var paymentMethod: String // Stored as raw value
    var categoryName: String
    var note: String
    var rawMessage: String
    var upiRefNumber: String
    
    init(
        id: UUID = UUID(),
        merchantName: String,
        amount: Double,
        date: Date = Date(),
        paymentMethod: PaymentMethod = .upi,
        categoryName: String = "Other",
        note: String = "",
        rawMessage: String = "",
        upiRefNumber: String = ""
    ) {
        self.id = id
        self.merchantName = merchantName
        self.amount = amount
        self.date = date
        self.paymentMethod = paymentMethod.rawValue
        self.categoryName = categoryName
        self.note = note
        self.rawMessage = rawMessage
        self.upiRefNumber = upiRefNumber
    }
    
    // MARK: - Computed Properties
    
    var payment: PaymentMethod {
        PaymentMethod(rawValue: paymentMethod) ?? .upi
    }
    
    var formattedAmount: String {
        amount.currencyFormatted
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    var fullDateTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, h:mm a"
        return formatter.string(from: date)
    }
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        if interval < 172800 { return "Yesterday" }
        if interval < 604800 { return "\(Int(interval / 86400))d ago" }
        return dateFormatted
    }
    
    var categoryInfo: CategoryInfo {
        CategoryInfo.all.first { $0.name == categoryName } ?? CategoryInfo.other
    }
}
