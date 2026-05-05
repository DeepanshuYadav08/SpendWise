import SwiftUI

struct CategoryIcon: View {
    let category: CategoryInfo
    let size: CGFloat
    let showGlow: Bool
    
    init(_ category: CategoryInfo, size: CGFloat = 40, showGlow: Bool = true) {
        self.category = category
        self.size = size
        self.showGlow = category.isRiskCategory && showGlow
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(category.color.opacity(0.15))
                .frame(width: size, height: size)
            
            if showGlow {
                Circle()
                    .fill(category.color.opacity(0.1))
                    .frame(width: size + 8, height: size + 8)
                    .blur(radius: 4)
            }
            
            Image(systemName: category.icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(category.color)
        }
        .frame(width: size + (showGlow ? 8 : 0), height: size + (showGlow ? 8 : 0))
    }
}

struct CategoryChip: View {
    let category: CategoryInfo
    let isSelected: Bool
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isSelected ? category.color : theme.secondaryText)
            Text(category.name)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isSelected ? category.color.opacity(0.25) : theme.surface)
                .overlay(Capsule().stroke(isSelected ? category.color.opacity(0.5) : theme.primaryText.opacity(0.1), lineWidth: 1))
        )
        .foregroundStyle(isSelected ? category.color : theme.secondaryText)
    }
}
