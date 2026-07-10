import SwiftUI

enum EscalationLevel {
    case informative    // golden amber
    case cautionary     // burnt orange
    case important      // burnt red-brown

    var accentColor: Color {
        switch self {
        case .informative: return Color.accentSecondary
        case .cautionary:  return Color.stateCaution
        case .important:   return Color.stateCritical
        }
    }

    var icon: String {
        switch self {
        case .informative: return "lightbulb.fill"
        case .cautionary:  return "exclamationmark.circle.fill"
        case .important:   return "bell.fill"
        }
    }
}

struct InsightCard: View {
    let message: String
    let level: EscalationLevel
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(alignment: .top, spacing: Spacing.s12) {
                Image(systemName: level.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(level.accentColor)
                    .frame(width: 28)

                Text(message)
                    .font(.cashflowCallout)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.cashflowCaption1)
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(Spacing.s16)
            .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(level.accentColor.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
