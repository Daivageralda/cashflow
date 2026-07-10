import SwiftUI

struct OnboardingPage1View: View {
    @Binding var userName: String
    let onNext: () -> Void
    var canProceed: Bool

    var body: some View {
        VStack(spacing: Spacing.s32) {
            Spacer()

            VStack(spacing: Spacing.s16) {
                Text("👋")
                    .font(.system(size: 64))

                Text("Halo! Siapa namamu?")
                    .font(.cashflowTitle2)
                    .foregroundStyle(Color.textPrimary)

                Text("Kami akan menyebutmu dengan nama ini di insight dan sapaan.")
                    .font(.cashflowBody)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }

            TextField("Nama kamu", text: $userName)
                .font(.cashflowBody)
                .padding(Spacing.s16)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.borderDefault, lineWidth: 1)
                )

            Spacer()

            PrimaryButton(title: "Lanjut") { onNext() }
                .disabled(!canProceed)
                .opacity(canProceed ? 1 : 0.5)
        }
        .padding(.horizontal, Spacing.s24)
        .padding(.bottom, Spacing.s32)
    }
}
