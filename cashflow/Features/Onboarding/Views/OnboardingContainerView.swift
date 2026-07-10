import SwiftUI

struct OnboardingContainerView: View {
    @State private var viewModel: OnboardingViewModel
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    init(appState: AppState) {
        _viewModel = State(wrappedValue: OnboardingViewModel(appState: appState))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.bgPrimary.ignoresSafeArea()

            VStack {
                HStack(spacing: Spacing.s8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index <= viewModel.currentPage ? Color.accentPrimary : Color.bgTertiary)
                            .frame(height: 4)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.currentPage)
                    }
                }
                .padding(.horizontal, Spacing.s24)
                .padding(.top, Spacing.s16)

                TabView(selection: $viewModel.currentPage) {
                    OnboardingPage1View(
                        userName: $viewModel.userName,
                        onNext: { viewModel.currentPage = 1 },
                        canProceed: viewModel.canProceedFromPage1
                    )
                    .tag(0)

                    OnboardingPage2View(
                        selectedCurrency: $viewModel.selectedCurrency,
                        onNext: { viewModel.currentPage = 2 }
                    )
                    .tag(1)

                    OnboardingPage3View(
                        balanceText: Binding(
                            get: { viewModel.initialBalanceText },
                            set: { viewModel.initialBalanceText = $0 }
                        ),
                        currency: viewModel.selectedCurrency,
                        onComplete: { viewModel.completeOnboarding(context: modelContext) }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.currentPage)
            }
        }
    }
}
