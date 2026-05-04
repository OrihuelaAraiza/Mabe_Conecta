import SwiftUI

struct SkeletonView: View {
    var height: CGFloat = 18
    var cornerRadius: CGFloat = 8
    @State private var opacity = 0.45

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.mabeGray200)
            .frame(height: height)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 1
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
