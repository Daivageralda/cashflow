import SwiftUI

struct BudgetProgressBar: View {
    let ratio: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.bgTertiary)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(barColor)
                    .frame(width: geo.size.width * min(ratio, 1.0), height: height)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: ratio)
            }
        }
        .frame(height: height)
    }

    private var barColor: Color {
        if ratio >= 1.0 { return Color.stateCritical }
        if ratio >= 0.8 { return Color.stateCaution }
        return Color.accentSecondary
    }
}
