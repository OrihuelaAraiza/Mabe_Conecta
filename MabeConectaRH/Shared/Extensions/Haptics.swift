import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum Haptics {
    enum ImpactStyle {
        case light
        case medium
    }

    static func impact(_ style: ImpactStyle = .light) {
        #if canImport(UIKit)
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle = style == .medium ? .medium : .light
        UIImpactFeedbackGenerator(style: uiStyle).impactOccurred()
        #endif
    }
}
