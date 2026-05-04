import SwiftUI

enum MabeNavigationTitleDisplayMode {
    case large
    case inline
}

extension View {
    @ViewBuilder
    func mabeNavigationBarTitleDisplayMode(_ displayMode: MabeNavigationTitleDisplayMode) -> some View {
        #if os(iOS)
        switch displayMode {
        case .large:
            self.navigationBarTitleDisplayMode(.large)
        case .inline:
            self.navigationBarTitleDisplayMode(.inline)
        }
        #else
        self
        #endif
    }
}
