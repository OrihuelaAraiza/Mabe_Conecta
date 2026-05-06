import SwiftUI

struct MabeIndustrialPattern: View {
    var opacity: Double = 0.06
    var color: Color = .white

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let spacing: CGFloat = 24
                let height = max(size.height, proxy.size.height)
                var x: CGFloat = -height

                while x < size.width + height {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + height, y: height))
                    context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: 0.5)
                    x += spacing
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
