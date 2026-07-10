import SwiftUI

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.isFirstLaunch {
                OnboardingContainerView(appState: appState)
            } else if !appState.isAuthenticated {
                AuthLockView(appState: appState)
            } else {
                MainTabView()
            }
        }
        .environment(appState)
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: appState.isFirstLaunch)
    }
}

