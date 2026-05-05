import Foundation

// MARK: - Parsed Transaction Result
struct ParsedTransaction {
    var merchantName: String
    var amount: Double
    var date: Date
    var paymentMethod: PaymentMethod
    var upiRefNumber: String
    var rawMessage: String
    var isDebit: Bool
    
    var isValid: Bool {
        amount > 0 && !merchantName.isEmpty && isDebit
    }
}

// MARK: - UPI Parser Service
final class UPIParserService: @unchecked Sendable {
    
    static let shared = UPIParserService()
    private init() {}
    
    // MARK: - Main Parse Function
    
    func parse(_ message: String) -> ParsedTransaction? {
        let cleaned = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it's a credit (ignore credits)
        if isCreditMessage(cleaned) {
            return nil
        }
        
        // Try various UPI message formats
        if let result = parseFormat1(cleaned) { return result }
        if let result = parseFormat2(cleaned) { return result }
        if let result = parseFormat3(cleaned) { return result }
        if let result = parseFormat4(cleaned) { return result }
        if let result = parseFormat5(cleaned) { return result }
        if let result = parseGeneric(cleaned) { return result }
        
        return nil
    }
    
    // MARK: - Credit Detection
    
    private func isCreditMessage(_ message: String) -> Bool {
        let creditKeywords = ["credited", "received", "cashback", "refund", "reversed",
                              "credit", "deposited", "added to", "money received"]
        let lower = message.lowercased()
        return creditKeywords.contains { lower.contains($0) }
    }
    
    // MARK: - Format Parsers
    
    // Format 1: "₹{amount} debited from A/c {account} to {merchant} on {date}"
    private func parseFormat1(_ message: String) -> ParsedTransaction? {
        let pattern = #"(?:Rs\.?|₹|INR)\s*([0-9,]+\.?\d*)\s*(?:debited|deducted)\s*(?:from\s*(?:A/?c|account)\s*\w+)?\s*(?:to|for)\s+(.+?)(?:\s+on\s+(.+?))?(?:\s+(?:UPI\s*(?:Ref|ref|ID)?\.?\s*:?\s*(\d+)))?\.?\s*$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)) else {
            return nil
        }
        
        return extractTransaction(from: match, in: message)
    }
    
    // Format 2: "Paid ₹{amount} to {merchant} via UPI"
    private func parseFormat2(_ message: String) -> ParsedTransaction? {
        let pattern = #"(?:Paid|Sent)\s*(?:Rs\.?|₹|INR)\s*([0-9,]+\.?\d*)\s*(?:to|for)\s+(.+?)(?:\s+(?:via|using|through)\s+(\w+))?(?:\s+(?:UPI\s*(?:Ref|ref|ID)?\.?\s*:?\s*(\d+)))?\.?\s*$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)) else {
            return nil
        }
        
        return extractTransaction(from: match, in: message)
    }
    
    // Format 3: "Rs.{amount} sent to {merchant} UPI Ref: {ref}"
    private func parseFormat3(_ message: String) -> ParsedTransaction? {
        let pattern = #"(?:Rs\.?|₹|INR)\s*([0-9,]+\.?\d*)\s*(?:sent|transferred|paid)\s*(?:to|for)\s+(.+?)(?:\s+(?:UPI\s*(?:Ref|ref|ID)?\.?\s*:?\s*(\d+)))?\.?\s*$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)) else {
            return nil
        }
        
        return extractTransaction(from: match, in: message)
    }
    
    // Format 4: "You've paid ₹{amount} to {merchant}"
    private func parseFormat4(_ message: String) -> ParsedTransaction? {
        let pattern = #"(?:You(?:'ve|'ve| have)?\s*(?:paid|spent|debited))\s*(?:Rs\.?|₹|INR)\s*([0-9,]+\.?\d*)\s*(?:to|at|for|on)\s+(.+?)(?:\s+(?:UPI\s*(?:Ref|ref|ID)?\.?\s*:?\s*(\d+)))?\.?\s*$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)) else {
            return nil
        }
        
        return extractTransaction(from: match, in: message)
    }
    
    // Format 5: "Dear Customer, ₹{amount} has been debited from your account for {merchant}"
    private func parseFormat5(_ message: String) -> ParsedTransaction? {
        let pattern = #"(?:Dear\s+Customer,?\s*)?(?:Rs\.?|₹|INR)\s*([0-9,]+\.?\d*)\s*(?:has been|is)\s*(?:debited|deducted)\s*(?:from\s*(?:your)?\s*(?:A/?c|account)\s*\w*)?\s*(?:to|for|towards)\s+(.+?)(?:\s+on\s+(.+?))?(?:\s+(?:UPI\s*(?:Ref|ref|ID)?\.?\s*:?\s*(\d+)))?\.?\s*$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)) else {
            return nil
        }
        
        return extractTransaction(from: match, in: message)
    }
    
    // Generic: Just find amount and merchant-like words
    private func parseGeneric(_ message: String) -> ParsedTransaction? {
        // Try to extract amount
        let amountPattern = #"(?:Rs\.?|₹|INR)\s*([0-9,]+\.?\d*)"#
        guard let amountRegex = try? NSRegularExpression(pattern: amountPattern, options: [.caseInsensitive]),
              let amountMatch = amountRegex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
              let amountRange = Range(amountMatch.range(at: 1), in: message) else {
            return nil
        }
        
        let amountStr = message[amountRange].replacingOccurrences(of: ",", with: "")
        guard let amount = Double(amountStr), amount > 0 else { return nil }
        
        // Check it's a debit
        let debitKeywords = ["debit", "paid", "sent", "spent", "payment", "transfer"]
        let lower = message.lowercased()
        guard debitKeywords.contains(where: { lower.contains($0) }) else { return nil }
        
        // Try to find merchant after "to" or "at" or "for"
        let merchantPattern = #"(?:to|at|for)\s+([A-Za-z0-9\s]+?)(?:\s+(?:on|via|using|UPI|Ref)|\.|$)"#
        var merchant = "Unknown Merchant"
        if let merchantRegex = try? NSRegularExpression(pattern: merchantPattern, options: [.caseInsensitive]),
           let merchantMatch = merchantRegex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
           let merchantRange = Range(merchantMatch.range(at: 1), in: message) {
            merchant = String(message[merchantRange]).trimmingCharacters(in: .whitespaces)
        }
        
        // Extract UPI ref
        let refPattern = #"(?:UPI\s*(?:Ref|ref|ID)?\.?\s*:?\s*(\d+))"#
        var ref = ""
        if let refRegex = try? NSRegularExpression(pattern: refPattern, options: [.caseInsensitive]),
           let refMatch = refRegex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
           let refRange = Range(refMatch.range(at: 1), in: message) {
            ref = String(message[refRange])
        }
        
        return ParsedTransaction(
            merchantName: merchant,
            amount: amount,
            date: Date(),
            paymentMethod: .upi,
            upiRefNumber: ref,
            rawMessage: message,
            isDebit: true
        )
    }
    
    // MARK: - Helpers
    
    private func extractTransaction(from match: NSTextCheckingResult, in message: String) -> ParsedTransaction? {
        // Amount (group 1)
        guard let amountRange = Range(match.range(at: 1), in: message) else { return nil }
        let amountStr = message[amountRange].replacingOccurrences(of: ",", with: "")
        guard let amount = Double(amountStr), amount > 0 else { return nil }
        
        // Merchant (group 2)
        var merchant = "Unknown Merchant"
        if match.numberOfRanges > 2, let merchantRange = Range(match.range(at: 2), in: message) {
            merchant = String(message[merchantRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            // Clean up merchant name
            merchant = cleanMerchantName(merchant)
        }
        
        // UPI Reference (last group typically)
        var ref = ""
        for i in stride(from: match.numberOfRanges - 1, through: 3, by: -1) {
            if let range = Range(match.range(at: i), in: message) {
                let val = String(message[range])
                if val.allSatisfy({ $0.isNumber }) {
                    ref = val
                    break
                }
            }
        }
        
        // Detect payment method
        let lower = message.lowercased()
        var method: PaymentMethod = .upi
        if lower.contains("card") || lower.contains("credit") || lower.contains("debit card") {
            method = .card
        } else if lower.contains("wallet") || lower.contains("paytm wallet") {
            method = .wallet
        } else if lower.contains("neft") || lower.contains("imps") || lower.contains("rtgs") {
            method = .bank
        }
        
        return ParsedTransaction(
            merchantName: merchant,
            amount: amount,
            date: Date(),
            paymentMethod: method,
            upiRefNumber: ref,
            rawMessage: message,
            isDebit: true
        )
    }
    
    private func cleanMerchantName(_ name: String) -> String {
        var cleaned = name
        // Remove common suffixes
        let suffixes = ["pvt", "ltd", "private", "limited", "inc", "llp", "llc"]
        for suffix in suffixes {
            cleaned = cleaned.replacingOccurrences(of: suffix, with: "", options: .caseInsensitive)
        }
        // Trim and capitalize
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
        if !cleaned.isEmpty {
            cleaned = cleaned.prefix(1).uppercased() + cleaned.dropFirst()
        }
        return cleaned.isEmpty ? "Unknown Merchant" : cleaned
    }
}
