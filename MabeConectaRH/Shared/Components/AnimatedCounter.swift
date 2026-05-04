import SwiftUI

struct AnimatedCounter: View {
    let value: Int
    @State private var displayValue = 0

    var body: some View {
        Text("\(displayValue)")
            .font(.mabeDisplay)
            .foregroundStyle(Color.mabeBlue)
            .contentTransition(.numericText())
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                    displayValue = value
                }
            }
    }
}
