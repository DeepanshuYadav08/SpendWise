import SwiftUI

struct AnimatedNumber: View {
    let value: Double
    let prefix: String
    let font: Font
    let color: Color
    
    @State private var animatedValue: Double = 0
    
    init(_ value: Double, prefix: String = "₹", font: Font = .title.bold(), color: Color = .white) {
        self.value = value
        self.prefix = prefix
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text("\(prefix)\(Int(animatedValue))")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText(value: animatedValue))
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { animatedValue = value } }
            .onChange(of: value) { _, new in withAnimation(.easeOut(duration: 0.5)) { animatedValue = new } }
    }
}
