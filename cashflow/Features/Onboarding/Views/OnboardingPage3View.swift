import SwiftUI

struct OnboardingPage3View: View {
    @Binding var balanceText: String
    var currency: SupportedCurrency
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s32) {
            Spacer()

            VStack(spacing: Spacing.s16) {
                Text("💰")
                    .font(.system(size: 64))

                Text("Berapa saldo awalmu?")
                    .font(.cashflowTitle2)
                    .foregroundStyle(Color.textPrimary)

                Text("Bisa dikosongkan dulu dan diisi nanti di Settings.")
                    .font(.cashflowBody)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: Spacing.s8) {
                Text(currency.symbol)
                    .font(.cashflowTitle2)
                    .foregroundStyle(Color.textSecondary)

                TextField("0", text: $balanceText)
                    .font(.cashflowTitle1)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.numberPad)
                    .cashflowMonospacedDigits()
            }
            .padding(Spacing.s16)
            .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))

            Spacer()

            VStack(spacing: Spacing.s12) {
                PrimaryButton(title: "Mulai Cashflow") { onComplete() }

                Button("Lewati dulu") { onComplete() }
                    .font(.cashflowCallout)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.s24)
        .padding(.bottom, Spacing.s32)
    }
}
