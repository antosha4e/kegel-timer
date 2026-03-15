import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine

    var body: some View {
        Group {
            if sessionEngine.state?.status == .completed {
                CompletionView()
            } else if sessionEngine.state != nil || appModel.isStartCountdownActive {
                SessionView()
            } else {
                HomeView()
            }
        }
        .tint(AppTheme.accent)
    }
}
