import SwiftUI

struct QuickInsightCardView: View {
    var message: String?
    var level: EscalationLevel = .informative
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let message {
            InsightCard(message: message, level: level, onTap: onTap)
                .transition(.move(edge: .top).combined(with: .opacity))
        } else {
            InsightCard(
                message: "Mulai catat transaksi untuk mendapatkan insight keuangan personalmu.",
                level: .informative
            )
        }
    }
}
