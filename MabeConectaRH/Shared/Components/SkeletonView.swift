import SwiftUI

struct SkeletonView: View {
    var height: CGFloat = 18
    var cornerRadius: CGFloat = 8
    @State private var phase: CGFloat = -0.3

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.mabeGray200, location: phase - 0.3),
                        .init(color: Color.mabeGray100, location: phase),
                        .init(color: Color.mabeGray200, location: phase + 0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
            .accessibilityHidden(true)
    }
}

extension View {
    func shimmer() -> some View {
        redacted(reason: .placeholder)
    }
}
