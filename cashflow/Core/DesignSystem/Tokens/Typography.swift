import SwiftUI

extension Font {
    // Display — SF Pro Display, hanya untuk ≥ 20pt
    static let cashflowLargeTitle = Font.largeTitle.weight(.bold)          // 34pt Bold
    static let cashflowTitle1     = Font.title.weight(.bold)               // 28pt Bold
    static let cashflowTitle2     = Font.title2.weight(.semibold)          // 22pt Semibold
    static let cashflowTitle3     = Font.title3.weight(.semibold)          // 20pt Semibold

    // Text — SF Pro Text
    static let cashflowHeadline    = Font.headline                         // 17pt Semibold
    static let cashflowBody        = Font.body                             // 17pt Regular
    static let cashflowCallout     = Font.callout                          // 16pt Regular
    static let cashflowSubheadline = Font.subheadline                      // 15pt Regular
    static let cashflowFootnote    = Font.footnote                         // 13pt Regular
    static let cashflowCaption1    = Font.caption                          // 12pt Regular
    static let cashflowCaption2    = Font.caption2.weight(.medium)         // 11pt Medium
}

// Untuk angka saldo/nominal — Tabular Figures agar tidak bergoyang saat berubah
extension View {
    func cashflowMonospacedDigits() -> some View {
        self.monospacedDigit()
    }
}
