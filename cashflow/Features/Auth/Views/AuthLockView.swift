import SwiftUI

struct AuthLockView: View {
    @State private var viewModel: AuthViewModel
    @Environment(AppState.self) private var appState

    init(appState: AppState) {
        _viewModel = State(wrappedValue: AuthViewModel(
            service: BiometricAuthService(),
            appState: appState
        ))
    }

    var body: some View {
        VStack(spacing: Spacing.s32) {
            Spacer()

            VStack(spacing: Spacing.s16) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)

                Text("Masuk untuk melanjutkan")
                    .font(.cashflowBody)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            if case .failed(let message) = viewModel.authState {
                Text(message)
                    .font(.cashflowSubheadline)
                    .foregroundStyle(Color.stateCaution)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.s32)
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
            }

            VStack(spacing: Spacing.s16) {
                Button {
                    Task { await viewModel.attemptAuth() }
                } label: {
                    HStack(spacing: Spacing.s8) {
                        Image(systemName: faceIDIcon)
                            .font(.cashflowHeadline)
                        Text(authButtonLabel)
                            .font(.cashflowHeadline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.s16)
                    .background(Color.accentPrimary, in: RoundedRectangle(cornerRadius: Radius.sm))
                }
                .disabled(viewModel.authState == .authenticating)

                Button("Gunakan Passcode") {
                    Task { await viewModel.attemptAuth() }
                }
                .font(.cashflowCallout)
                .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, Spacing.s24)
            .padding(.bottom, Spacing.s48)
        }
        .background(Color.bgPrimary)
        .task {
            await viewModel.attemptAuth()
        }
    }

    private var faceIDIcon: String {
        "faceid"
    }

    private var authButtonLabel: String {
        viewModel.authState == .authenticating ? "Memverifikasi..." : "Masuk dengan Face ID"
    }
}
