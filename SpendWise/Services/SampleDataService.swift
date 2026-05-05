import Foundation
import SwiftData

final class SampleDataService: @unchecked Sendable {
    static let shared = SampleDataService()
    private init() {}
    
    func generateSampleTransactions() -> [Transaction] {
        var transactions: [Transaction] = []
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            
            // Daily cigarette (pattern detection target)
            if Int.random(in: 0...10) > 2 {
                let h = Int.random(in: 8...11)
                let d = calendar.date(bySettingHour: h, minute: Int.random(in: 0...59), second: 0, of: date)!
                transactions.append(Transaction(merchantName: ["Pan Corner","Sharma Pan Shop","Corner Shop"].randomElement()!, amount: Double([20,25,30].randomElement()!), date: d, paymentMethod: .upi, categoryName: "Cigarettes"))
            }
            
            // Food (3-5x/week)
            if dayOffset % 2 == 0 || Int.random(in: 0...3) == 0 {
                let m = [("Swiggy",150...450),("Zomato",180...500),("Dominos Pizza",300...600),("McDonald's",150...350),("KFC",200...400),("Local Dhaba",80...150),("Chai Point",40...80)].randomElement()!
                let h = [12,13,19,20,21,22].randomElement()!
                let d = calendar.date(bySettingHour: h, minute: Int.random(in: 0...59), second: 0, of: date)!
                transactions.append(Transaction(merchantName: m.0, amount: Double(Int.random(in: m.1)), date: d, paymentMethod: .upi, categoryName: "Food"))
            }
            
            // Travel
            if dayOffset % 3 == 0 {
                let m = [("Uber",80...350),("Ola",70...300),("Rapido",40...150),("Metro Recharge",50...100)].randomElement()!
                let h = [8,9,17,18,19].randomElement()!
                let d = calendar.date(bySettingHour: h, minute: Int.random(in: 0...59), second: 0, of: date)!
                transactions.append(Transaction(merchantName: m.0, amount: Double(Int.random(in: m.1)), date: d, paymentMethod: .upi, categoryName: "Travel"))
            }
            
            // Shopping
            if dayOffset % 5 == 0 {
                let m = [("Amazon",500...3000),("Flipkart",400...2500),("Myntra",600...2000),("Blinkit",150...600)].randomElement()!
                let h = Int.random(in: 10...22)
                let d = calendar.date(bySettingHour: h, minute: Int.random(in: 0...59), second: 0, of: date)!
                transactions.append(Transaction(merchantName: m.0, amount: Double(Int.random(in: m.1)), date: d, paymentMethod: [.upi,.card].randomElement()!, categoryName: "Shopping"))
            }
            
            // Bills (monthly)
            if dayOffset == 1 || dayOffset == 30 || dayOffset == 60 {
                for b in [("Airtel Recharge",299...699),("Electricity Bill",800...2500)].prefix(2) {
                    let d = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!
                    transactions.append(Transaction(merchantName: b.0, amount: Double(Int.random(in: b.1)), date: d, paymentMethod: .upi, categoryName: "Bills"))
                }
            }
            
            // Subscriptions
            if dayOffset == 5 || dayOffset == 35 || dayOffset == 65 {
                let s = [("Netflix",199),("Spotify",119),("Disney+ Hotstar",299),("YouTube Premium",129)].randomElement()!
                let d = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: date)!
                transactions.append(Transaction(merchantName: s.0, amount: Double(s.1), date: d, paymentMethod: .card, categoryName: "Subscriptions"))
            }
            
            // Groceries (weekly)
            if dayOffset % 7 == 0 {
                let m = [("BigBasket",400...1200),("DMart",500...2000),("JioMart",300...1000)].randomElement()!
                let d = calendar.date(bySettingHour: 11, minute: 30, second: 0, of: date)!
                transactions.append(Transaction(merchantName: m.0, amount: Double(Int.random(in: m.1)), date: d, paymentMethod: .upi, categoryName: "Groceries"))
            }
            
            // Alcohol (weekends)
            if dayOffset % 7 == 5 && Int.random(in: 0...2) == 0 {
                let d = calendar.date(bySettingHour: Int.random(in: 19...23), minute: 0, second: 0, of: date)!
                transactions.append(Transaction(merchantName: ["Wine Shop","The Pub","Liquor Store"].randomElement()!, amount: Double(Int.random(in: 300...1500)), date: d, paymentMethod: .upi, categoryName: "Alcohol"))
            }
            
            // Health (occasional)
            if dayOffset == 10 || dayOffset == 45 || dayOffset == 75 {
                let d = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: date)!
                transactions.append(Transaction(merchantName: ["Apollo Pharmacy","MedPlus","Gym"].randomElement()!, amount: Double(Int.random(in: 200...1500)), date: d, paymentMethod: .upi, categoryName: "Health"))
            }
        }
        
        transactions.sort { $0.date > $1.date }
        return transactions
    }
    
    func loadSampleData(into context: ModelContext) {
        let transactions = generateSampleTransactions()
        for t in transactions { context.insert(t) }
        try? context.save()
    }
}
