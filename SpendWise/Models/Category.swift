import Foundation
import SwiftUI

// MARK: - Category Info (Static data, not persisted)
struct CategoryInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String       // SF Symbol name
    let emoji: String
    let color: Color
    let isRiskCategory: Bool
    let keywords: [String]
    
    // MARK: - Pre-seeded Categories
    
    static let food = CategoryInfo(
        id: "food", name: "Food", icon: "fork.knife", emoji: "🍔",
        color: .orange, isRiskCategory: false,
        keywords: ["swiggy", "zomato", "dominos", "pizza", "mcdonald", "burger", "kfc", "subway",
                    "restaurant", "cafe", "biryani", "food", "eat", "meal", "lunch", "dinner",
                    "breakfast", "dhaba", "kitchen", "bakery", "starbucks", "chaayos"]
    )
    
    static let travel = CategoryInfo(
        id: "travel", name: "Travel", icon: "car.fill", emoji: "🚕",
        color: .blue, isRiskCategory: false,
        keywords: ["uber", "ola", "rapido", "irctc", "redbus", "makemytrip", "goibibo",
                    "indigo", "spicejet", "airlines", "flight", "train", "cab", "taxi",
                    "auto", "metro", "bus", "petrol", "diesel", "fuel", "parking"]
    )
    
    static let shopping = CategoryInfo(
        id: "shopping", name: "Shopping", icon: "cart.fill", emoji: "🛒",
        color: .pink, isRiskCategory: false,
        keywords: ["amazon", "flipkart", "myntra", "meesho", "ajio", "nykaa", "snapdeal",
                    "shopping", "store", "mall", "market", "shop", "buy", "retail",
                    "dmart", "reliance", "bigbasket", "blinkit", "zepto", "instamart"]
    )
    
    static let bills = CategoryInfo(
        id: "bills", name: "Bills", icon: "doc.text.fill", emoji: "📄",
        color: .green, isRiskCategory: false,
        keywords: ["airtel", "jio", "vodafone", "vi", "bsnl", "electricity", "water",
                    "gas", "rent", "maintenance", "insurance", "emi", "loan", "bill",
                    "recharge", "postpaid", "broadband", "wifi", "internet"]
    )
    
    static let entertainment = CategoryInfo(
        id: "entertainment", name: "Entertainment", icon: "film.fill", emoji: "🎬",
        color: .purple, isRiskCategory: false,
        keywords: ["netflix", "hotstar", "prime", "spotify", "youtube", "cinema",
                    "movie", "theatre", "gaming", "game", "play", "concert", "event",
                    "bookmyshow", "pvr", "inox", "disney"]
    )
    
    static let health = CategoryInfo(
        id: "health", name: "Health", icon: "heart.fill", emoji: "💊",
        color: .red, isRiskCategory: false,
        keywords: ["pharmacy", "medical", "hospital", "doctor", "clinic", "medicine",
                    "apollo", "medplus", "netmeds", "pharmeasy", "1mg", "gym", "fitness",
                    "yoga", "health", "lab", "test", "diagnostic"]
    )
    
    static let groceries = CategoryInfo(
        id: "groceries", name: "Groceries", icon: "leaf.fill", emoji: "🥬",
        color: .mint, isRiskCategory: false,
        keywords: ["grocery", "vegetables", "fruits", "milk", "dairy", "kirana",
                    "supermarket", "provision", "ration", "bigbasket", "grofers",
                    "jiomart", "spencers", "more", "fresh"]
    )
    
    static let subscriptions = CategoryInfo(
        id: "subscriptions", name: "Subscriptions", icon: "arrow.triangle.2.circlepath", emoji: "📱",
        color: .indigo, isRiskCategory: false,
        keywords: ["subscription", "monthly", "annual", "premium", "pro", "plus",
                    "icloud", "apple", "google", "microsoft", "adobe", "notion"]
    )
    
    static let education = CategoryInfo(
        id: "education", name: "Education", icon: "book.fill", emoji: "📚",
        color: .teal, isRiskCategory: false,
        keywords: ["school", "college", "university", "course", "udemy", "coursera",
                    "unacademy", "byju", "book", "stationery", "tuition", "coaching",
                    "education", "learning", "exam", "fee"]
    )
    
    static let cigarettes = CategoryInfo(
        id: "cigarettes", name: "Cigarettes", icon: "smoke.fill", emoji: "🚬",
        color: Color(red: 0.8, green: 0.3, blue: 0.2), isRiskCategory: true,
        keywords: ["cigarette", "tobacco", "smoke", "pan", "gutka", "beedi"]
    )
    
    static let alcohol = CategoryInfo(
        id: "alcohol", name: "Alcohol", icon: "wineglass.fill", emoji: "🍺",
        color: Color(red: 0.7, green: 0.5, blue: 0.1), isRiskCategory: true,
        keywords: ["alcohol", "beer", "wine", "liquor", "bar", "pub", "brewery",
                    "whiskey", "vodka", "rum", "cocktail", "drinks"]
    )
    
    static let junkFood = CategoryInfo(
        id: "junkfood", name: "Junk Food", icon: "flame.fill", emoji: "🍟",
        color: Color(red: 0.9, green: 0.4, blue: 0.3), isRiskCategory: true,
        keywords: ["chips", "snack", "candy", "chocolate", "soda", "cola", "pepsi",
                    "coke", "fries", "junk"]
    )
    
    static let transfer = CategoryInfo(
        id: "transfer", name: "Transfer", icon: "arrow.left.arrow.right", emoji: "💸",
        color: .cyan, isRiskCategory: false,
        keywords: ["transfer", "sent", "paid", "payment"]
    )
    
    static let other = CategoryInfo(
        id: "other", name: "Other", icon: "ellipsis.circle.fill", emoji: "📦",
        color: .gray, isRiskCategory: false,
        keywords: []
    )
    
    // MARK: - All Categories
    
    static let all: [CategoryInfo] = [
        food, travel, shopping, bills, entertainment, health, groceries,
        subscriptions, education, cigarettes, alcohol, junkFood, transfer, other
    ]
    
    static let mainCategories: [CategoryInfo] = [
        food, travel, shopping, bills, entertainment, health, groceries,
        subscriptions, education, other
    ]
    
    static let riskCategories: [CategoryInfo] = [
        cigarettes, alcohol, junkFood
    ]
}
