import SwiftUI

struct OnboardingPage2View: View {
    @Binding var selectedCurrency: SupportedCurrency
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s32) {
            Spacer()

            VStack(spacing: Spacing.s16) {
                Text("💱")
                    .font(.system(size: 64))

                Text("Mata uang utama?")
                    .font(.cashflowTitle2)
                    .foregroundStyle(Color.textPrimary)

                Text("Semua nominal akan ditampilkan dalam format ini.")
                    .font(.cashflowBody)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: Spacing.s8) {
                ForEach(SupportedCurrency.allCases) { currency in
                    Button {
                        selectedCurrency = currency
                    } label: {
                        HStack {
                            Text(currency.symbol)
                                .font(.cashflowHeadline)
                                .foregroundStyle(Color.accentPrimary)
                                .frame(width: 40)

                            Text(currency.displayName)
                                .font(.cashflowBody)
                                .foregroundStyle(Color.textPrimary)

                            Spacer()

                            if selectedCurrency == currency {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentPrimary)
                            }
                        }
                        .padding(Spacing.s16)
                        .background(
                            selectedCurrency == currency ? Color.accentPrimary.opacity(0.08) : Color.bgSecondary,
                            in: RoundedRectangle(cornerRadius: Radius.md)
                        )
                    }
                }
            }

            Spacer()

            PrimaryButton(title: "Lanjut") { onNext() }
        }
        .padding(.horizontal, Spacing.s24)
        .padding(.bottom, Spacing.s32)
    }
}
