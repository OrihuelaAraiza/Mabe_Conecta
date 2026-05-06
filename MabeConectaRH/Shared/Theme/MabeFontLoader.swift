import CoreText
import Foundation

enum MabeFontLoader {
    private static var didRegister = false

    static func registerFonts() {
        guard !didRegister else { return }
        didRegister = true

        [
            "PlusJakartaSans-Regular",
            "PlusJakartaSans-Medium",
            "PlusJakartaSans-SemiBold",
            "PlusJakartaSans-Bold",
            "PlusJakartaSans-ExtraBold"
        ].forEach { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
