import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine
    @State private var isHintVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 28)

                timerCluster
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 16)

                presetRail
                    .padding(.horizontal, 18)
                    .padding(.bottom, 26)

                controlDock
            }
        }
        .preferredColorScheme(.dark)
    }

    private var timerCluster: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.accent.opacity(0.22),
                            AppTheme.accent.opacity(0.94)
                        ],
                        center: .center,
                        startRadius: 70,
                        endRadius: 250
                    )
                )
                .blur(radius: 30)
                .frame(width: 380, height: 380)
                .scaleEffect(isHoldPhase ? 1 : 0.9)
                .opacity(isHoldPhase ? 1 : 0)
                .animation(.easeInOut(duration: 0.45), value: isHoldPhase)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.canvasSecondary,
                            AppTheme.canvas
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 244, height: 244)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.18), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: max(stageProgress, 0.02))
                    .stroke(
                        .white.opacity(0.75),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))

                progressKnob(progress: stageProgress)

                VStack(spacing: 6) {
                    Text("\(displaySeconds)")
                        .font(.system(size: 82, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .monospacedDigit()

                    Text(displaySubtitle)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                }
            }
            .frame(width: 244, height: 244)

            Rectangle()
                .fill(.white.opacity(0.92))
                .frame(width: 4, height: 30)
                .clipShape(Capsule())
                .offset(y: 122)

            if isHintVisible {
                VStack(spacing: 10) {
                    Text(currentStage.subtitle)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white)
                    Text("\(currentStage.totalSeconds)s sec total • \(currentStage.squeezeSeconds)s squeeze • \(currentStage.relaxSeconds)s relax")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.panel.opacity(0.96))
                )
                .offset(y: -200)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    private var presetRail: some View {
        VStack(spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHintVisible.toggle()
                }
            } label: {
                Image(systemName: "questionmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.ink)
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .strokeBorder(.white.opacity(0.78), lineWidth: 2)
                    )
            }

            GeometryReader { geometry in
                let itemWidth: CGFloat = 126
                let itemSpacing: CGFloat = 28
                let stepWidth = itemWidth + itemSpacing
                let leadingInset = max((geometry.size.width - itemWidth) / 2, 0)

                HStack(spacing: itemSpacing) {
                    ForEach(Array(appModel.program.stages.enumerated()), id: \.element.id) { index, stage in
                        VStack(spacing: 10) {
                            Text(stage.name)
                                .font(.system(size: 19, weight: currentStageIndex == index ? .medium : .regular, design: .rounded))
                                .foregroundStyle(currentStageIndex == index ? AppTheme.ink : AppTheme.mutedInk)
                                .lineLimit(1)

                            Capsule()
                                .fill(currentStageIndex == index ? AppTheme.ink : .white.opacity(0.12))
                                .frame(width: 34, height: 4)
                        }
                        .frame(width: itemWidth)
                    }
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: leadingInset - (CGFloat(currentStageIndex) * stepWidth))
                .animation(.easeInOut(duration: 0.35), value: currentStageIndex)
            }
            .frame(height: 42)
            .clipped()
        }
    }

    private var controlDock: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(.white.opacity(0.12))
                .frame(width: 72, height: 5)
                .padding(.top, 10)

            Button(action: primaryAction) {
                HStack(spacing: 14) {
                    Image(systemName: primaryButtonSystemImage)
                        .font(.system(size: 20, weight: .bold))
                    Text(primaryButtonTitle)
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(AppTheme.panelSecondary)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 22)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(AppTheme.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var currentState: SessionState? {
        sessionEngine.state
    }

    private var currentStage: WorkoutStage {
        currentState?.stage ?? appModel.program.stages[0]
    }

    private var currentStageIndex: Int {
        if let currentState {
            return max(0, currentState.currentStageIndex - 1)
        }
        return 0
    }

    private var isHoldPhase: Bool {
        currentState?.phase == .squeeze
    }

    private var displaySubtitle: String {
        if let state = currentState {
            if state.status == .completed {
                return "Done"
            }
            return state.phase.title
        }
        return currentStage.name
    }

    private var displaySeconds: Int {
        if let state = currentState {
            if state.status == .completed {
                return 0
            }
            return state.secondsRemainingInStage
        }
        return currentStage.totalSeconds
    }

    private var stageProgress: Double {
        if let state = currentState {
            if state.status == .completed {
                return 1
            }
            return state.stageProgress
        }
        return 0
    }

    private var primaryButtonTitle: String {
        guard let state = currentState else { return "Start" }
        switch state.status {
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .completed:
            return "Start Again"
        case .cancelled:
            return "Start"
        }
    }

    private var primaryButtonSystemImage: String {
        guard let state = currentState else { return "play.fill" }
        switch state.status {
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .completed:
            return "arrow.clockwise"
        case .cancelled:
            return "play.fill"
        }
    }

    private func primaryAction() {
        guard let state = currentState else {
            appModel.startSession()
            return
        }

        switch state.status {
        case .running:
            sessionEngine.pause(settings: appModel.settings)
        case .paused:
            sessionEngine.resume(settings: appModel.settings)
        case .completed:
            appModel.finishCompletedSession()
            appModel.startSession()
        case .cancelled:
            appModel.startSession()
        }
    }

    @ViewBuilder
    private func progressKnob(progress: Double) -> some View {
        let clamped = min(max(progress, 0), 1)
        let angle = Angle.degrees((clamped * 360) + 180)
        Circle()
            .fill(.white)
            .frame(width: 16, height: 16)
            .offset(y: -122)
            .rotationEffect(angle)
    }
}

#Preview("Idle") {
    HomeViewPreviewContainer(mode: .idle)
}

#Preview("Running") {
    HomeViewPreviewContainer(mode: .running)
}

#Preview("Paused") {
    HomeViewPreviewContainer(mode: .paused)
}

#Preview("Completed") {
    HomeViewPreviewContainer(mode: .completed)
}

private struct HomeViewPreviewContainer: View {
    enum Mode {
        case idle
        case running
        case paused
        case completed
    }

    @StateObject private var appModel = AppModel()
    let mode: Mode

    var body: some View {
        HomeView()
            .environmentObject(appModel)
            .environmentObject(appModel.sessionEngine)
            .task {
                configureIfNeeded()
            }
    }

    private func configureIfNeeded() {
        guard appModel.sessionEngine.state == nil else { return }

        switch mode {
        case .idle:
            break
        case .running:
            appModel.startSession()
        case .paused:
            appModel.startSession()
            appModel.sessionEngine.pause(settings: appModel.settings)
        case .completed:
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
