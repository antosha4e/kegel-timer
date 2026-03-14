import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine

    var body: some View {
        HomeView()
            .tint(AppTheme.accent)
        .fullScreenCover(isPresented: isSessionPresented) {
            ActiveSessionView()
                .environmentObject(appModel)
                .environmentObject(sessionEngine)
                .interactiveDismissDisabled()
        }
    }

    private var isSessionPresented: Binding<Bool> {
        Binding(
            get: { sessionEngine.state != nil },
            set: { shouldPresent in
                if !shouldPresent, sessionEngine.state?.status == .completed {
                    appModel.finishCompletedSession()
                }
            }
        )
    }
}
