import Foundation
import UserNotifications

final class NotificationService: @unchecked Sendable {
    static let shared = NotificationService()
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted { self.scheduleDailySummary() }
        }
    }
    
    func scheduleDailySummary() {
        let content = UNMutableNotificationContent()
        content.title = "📊 Daily Expense Summary"
        content.body = "Tap to see how much you spent today!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_summary", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleWeeklySummary() {
        let content = UNMutableNotificationContent()
        content.title = "📈 Weekly Report Ready!"
        content.body = "Check your weekly spending breakdown and insights."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_summary", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendBudgetAlert(spent: Double, budget: Double) {
        let percent = Int(spent / max(budget, 1) * 100)
        guard percent >= 80 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🚨 Budget Alert!"
        content.body = "You've used \(percent)% of your monthly budget. Time to slow down!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "budget_alert_\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendSavingsCheer(amount: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Great Saving!"
        content.body = "You saved ₹\(Int(amount)) this week! Keep it up!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "savings_\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
