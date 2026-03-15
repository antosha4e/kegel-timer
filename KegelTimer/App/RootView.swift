import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine
    @State private var isSettingsPresented = false

    var body: some View {
        GeometryReader { proxy in
            Group {
                if sessionEngine.state?.status == .completed {
                    CompletionView()
                } else if sessionEngine.state != nil || appModel.isStartCountdownActive {
                    SessionView()
                } else {
                    HomeView()
                }
            }
            .overlay(alignment: .topTrailing) {
                topControls(topInset: proxy.safeAreaInsets.top)
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationStack {
                SettingsView()
            }
        }
        .tint(AppTheme.accent)
    }

    private func topControls(topInset: CGFloat) -> some View {
        HStack(spacing: 12) {
            iconButton(systemName: "gearshape.fill") {
                isSettingsPresented = true
            }

            if appModel.isStartCountdownActive {
                iconButton(systemName: "xmark") {
                    appModel.cancelStartCountdown()
                }
            }
        }
        .padding(.top, topInset + 12)
        .padding(.trailing, 24)
    }

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.panel.opacity(0.94))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Home") {
    RootViewPreviewContainer(mode: .home)
}

#Preview("Session") {
    RootViewPreviewContainer(mode: .session)
}

#Preview("Completion") {
    RootViewPreviewContainer(mode: .completion)
}

private struct RootViewPreviewContainer: View {
    enum Mode {
        case home
        case session
        case completion
    }

    @StateObject private var appModel = AppModel()
    let mode: Mode

    var body: some View {
        RootView()
            .environmentObject(appModel)
            .environmentObject(appModel.sessionEngine)
            .task {
                configureIfNeeded()
            }
    }

    private func configureIfNeeded() {
        switch mode {
        case .home:
            appModel.finishCompletedSession()
        case .session:
            guard appModel.sessionEngine.state == nil else { return }
            appModel.startSession()
        case .completion:
            let snapshot = SessionSnapshot(
                program: appModel.program,
                startedAt: Date(timeIntervalSinceNow: -(appModel.program.totalDuration + 2)),
                accumulatedPauseInterval: 0,
                pausedAt: nil
            )
            appModel.sessionEngine.restore(from: snapshot, settings: appModel.settings)
        }
    }
}
