import SwiftUI

extension Color {
    // Backgrounds
    static let bgPrimary   = Color("bg/primary")
    static let bgSecondary = Color("bg/secondary")
    static let bgTertiary  = Color("bg/tertiary")

    // Text
    static let textPrimary   = Color("text/primary")
    static let textSecondary = Color("text/secondary")
    static let textTertiary  = Color("text/tertiary")

    // Accents
    static let accentPrimary   = Color("accent/primary")
    static let accentSecondary = Color("accent/secondary")
    static let supportBrown    = Color("support/brown")

    // States
    static let stateSuccess  = Color("state/success")
    static let stateCaution  = Color("state/caution")
    static let stateCritical = Color("state/critical")

    // Borders
    static let borderDefault = Color("border/default")

    // Hex String Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
