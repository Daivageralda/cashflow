import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                }
                Text(title)
                    .font(.cashflowHeadline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.s16)
            .background(Color.accentPrimary, in: RoundedRectangle(cornerRadius: Radius.sm))
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.15), value: isLoading)
    }
}
