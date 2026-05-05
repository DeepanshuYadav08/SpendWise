import UIKit

final class HapticManager: @unchecked Sendable {
    static let shared = HapticManager()
    private init() {}
    
    func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
