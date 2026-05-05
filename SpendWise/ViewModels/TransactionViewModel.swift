import SwiftUI
import SwiftData

@Observable
final class TransactionViewModel {
    var searchText = ""
    var selectedCategory: CategoryInfo?
    var selectedPaymentMethod: PaymentMethod?
    var sortNewestFirst = true
    
    // Add transaction state
    var isShowingAddSheet = false
    var addMode: AddMode = .manual
    var pasteText = ""
    var parsedResult: ParsedTransaction?
    
    // Manual entry
    var manualAmount = ""
    var manualMerchant = ""
    var manualCategory: CategoryInfo = .other
    var manualPaymentMethod: PaymentMethod = .upi
    var manualDate = Date()
    var manualNote = ""
    
    enum AddMode: String, CaseIterable { case manual = "Manual", paste = "Paste SMS" }
    
    func filteredTransactions(_ transactions: [Transaction]) -> [Transaction] {
        var result = transactions
        
        if !searchText.isEmpty {
            result = result.filter { $0.merchantName.localizedCaseInsensitiveContains(searchText) }
        }
        if let cat = selectedCategory {
            result = result.filter { $0.categoryName == cat.name }
        }
        if let method = selectedPaymentMethod {
            result = result.filter { $0.paymentMethod == method.rawValue }
        }
        
        result.sort { sortNewestFirst ? $0.date > $1.date : $0.date < $1.date }
        return result
    }
    
    func groupedTransactions(_ transactions: [Transaction]) -> [(String, [Transaction])] {
        let filtered = filteredTransactions(transactions)
        let grouped = Dictionary(grouping: filtered) { txn -> String in
            if txn.isToday { return "Today" }
            if txn.isYesterday { return "Yesterday" }
            if txn.isThisWeek { return "This Week" }
            if txn.isThisMonth { return "This Month" }
            return txn.date.monthName
        }
        
        let order = ["Today", "Yesterday", "This Week", "This Month"]
        return grouped.sorted { a, b in
            let aIdx = order.firstIndex(of: a.key) ?? 99
            let bIdx = order.firstIndex(of: b.key) ?? 99
            if aIdx != bIdx { return aIdx < bIdx }
            return (a.value.first?.date ?? .distantPast) > (b.value.first?.date ?? .distantPast)
        }
    }
    
    func parsePastedMessage() {
        parsedResult = UPIParserService.shared.parse(pasteText)
        if parsedResult != nil { HapticManager.shared.success() }
        else { HapticManager.shared.error() }
    }
    
    func saveTransaction(context: ModelContext) {
        let txn: Transaction
        
        if addMode == .paste, let parsed = parsedResult, parsed.isValid {
            let cat = CategorizationService.shared.categorize(merchantName: parsed.merchantName, amount: parsed.amount)
            txn = Transaction(
                merchantName: parsed.merchantName, amount: parsed.amount, date: parsed.date,
                paymentMethod: parsed.paymentMethod, categoryName: cat.category.name,
                rawMessage: parsed.rawMessage, upiRefNumber: parsed.upiRefNumber
            )
        } else {
            guard let amount = Double(manualAmount), amount > 0 else {
                HapticManager.shared.error(); return
            }
            txn = Transaction(
                merchantName: manualMerchant.isEmpty ? "Unknown" : manualMerchant,
                amount: amount, date: manualDate,
                paymentMethod: manualPaymentMethod, categoryName: manualCategory.name,
                note: manualNote
            )
        }
        
        context.insert(txn)
        try? context.save()
        resetForm()
        HapticManager.shared.success()
    }
    
    func deleteTransaction(_ txn: Transaction, context: ModelContext) {
        context.delete(txn)
        try? context.save()
        HapticManager.shared.medium()
    }
    
    private func resetForm() {
        pasteText = ""; parsedResult = nil
        manualAmount = ""; manualMerchant = ""
        manualCategory = .other; manualPaymentMethod = .upi
        manualDate = Date(); manualNote = ""
        isShowingAddSheet = false
    }
}
