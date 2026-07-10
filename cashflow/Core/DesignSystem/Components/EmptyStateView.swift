import SwiftUI

struct EmptyStateView: View {
    let icon: String        // SF Symbol name
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.s16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.textTertiary)

            VStack(spacing: Spacing.s8) {
                Text(title)
                    .font(.cashflowTitle3)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.cashflowBody)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.cashflowCallout)
                    .foregroundStyle(Color.accentPrimary)
                    .padding(.top, Spacing.s8)
            }
        }
        .padding(Spacing.s48)
        .opacity(1)
        .transition(.opacity.animation(.easeIn(duration: 0.3)))
    }
}
