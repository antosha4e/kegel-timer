import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine
    @State private var selectedPresetID = WorkoutPreset.defaults.first?.id ?? ""
    @State private var isHintVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer(minLength: 8)

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
        .onAppear {
            if let activeRoutine = sessionEngine.state?.routine,
               let matchedPreset = appModel.presets.first(where: { $0.asRoutine == activeRoutine }) {
                selectedPresetID = matchedPreset.id
            } else if selectedPresetID.isEmpty, let firstPreset = appModel.presets.first {
                selectedPresetID = firstPreset.id
            }
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Pelvic Floor")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.mutedInk)
                Text(displayTitle)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHintVisible.toggle()
                }
            } label: {
                Image(systemName: "questionmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.ink)
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .strokeBorder(.white.opacity(0.75), lineWidth: 2)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
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
                    .trim(from: 0, to: max(phaseProgress, 0.02))
                    .stroke(
                        .white.opacity(0.75),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                progressKnob(progress: phaseProgress)

                VStack(spacing: 6) {
                    Text("\(displaySeconds)")
                        .font(.system(size: 82, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .monospacedDigit()

                    Text(displaySubtitle)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
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
                    Text(currentPreset.subtitle)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white)
                    Text("\(currentPreset.squeezeSeconds)s squeeze • \(currentPreset.relaxSeconds)s relax • \(currentPreset.repetitions) reps")
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

            HStack(spacing: 28) {
                ForEach(appModel.presets) { preset in
                    Button {
                        guard canSwitchPreset else { return }
                        selectedPresetID = preset.id
                    } label: {
                        Text(preset.name)
                            .font(.system(size: 19, weight: selectedPresetID == preset.id ? .medium : .regular, design: .rounded))
                            .foregroundStyle(selectedPresetID == preset.id ? AppTheme.ink : AppTheme.mutedInk.opacity(canSwitchPreset ? 1 : 0.5))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSwitchPreset)
                }
            }
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

            HStack(spacing: 16) {
                metricPill(title: "Work", value: "\(currentPreset.squeezeSeconds)s")
                metricPill(title: "Release", value: "\(currentPreset.relaxSeconds)s")
                metricPill(title: "Reps", value: "\(currentPreset.repetitions)")
            }

            if let state = sessionEngine.state, state.status == .completed {
                Button("Reset Session") {
                    appModel.finishCompletedSession()
                }
                .font(.headline.weight(.medium))
                .foregroundStyle(AppTheme.mutedInk)
                .padding(.bottom, 10)
            } else {
                Color.clear
                    .frame(height: 10)
            }
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

    private var currentPreset: WorkoutPreset {
        appModel.presets.first(where: { $0.id == selectedPresetID }) ?? appModel.presets[0]
    }

    private var currentState: SessionState? {
        sessionEngine.state
    }

    private var canSwitchPreset: Bool {
        guard let state = currentState else { return true }
        return state.status == .completed
    }

    private var displayTitle: String {
        currentState?.routine.name ?? currentPreset.name
    }

    private var displaySubtitle: String {
        if let state = currentState {
            if state.status == .completed {
                return "Done"
            }
            return state.phase.title
        }
        return "Ready"
    }

    private var displaySeconds: Int {
        if let state = currentState {
            if state.status == .completed {
                return 0
            }
            return state.secondsRemainingInPhase
        }
        return currentPreset.squeezeSeconds
    }

    private var phaseProgress: Double {
        if let state = currentState {
            if state.status == .completed {
                return 1
            }
            return state.phaseProgress
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
            appModel.startPreset(currentPreset)
            return
        }

        switch state.status {
        case .running:
            sessionEngine.pause(settings: appModel.settings)
        case .paused:
            sessionEngine.resume(settings: appModel.settings)
        case .completed:
            appModel.finishCompletedSession()
            appModel.startPreset(currentPreset)
        case .cancelled:
            appModel.startPreset(currentPreset)
        }
    }

    @ViewBuilder
    private func metricPill(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.mutedInk)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.canvasSecondary)
        )
    }

    @ViewBuilder
    private func progressKnob(progress: Double) -> some View {
        let clamped = min(max(progress, 0), 1)
        let angle = Angle.degrees((clamped * 360) - 90)
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

        let preset = appModel.presets[1]

        switch mode {
        case .idle:
            break
        case .running:
            appModel.startPreset(preset)
        case .paused:
            appModel.startPreset(preset)
            appModel.sessionEngine.pause(settings: appModel.settings)
        case .completed:
            let snapshot = SessionSnapshot(
                routine: preset.asRoutine,
                startedAt: Date(timeIntervalSinceNow: -(preset.asRoutine.totalDuration + 2)),
                accumulatedPauseInterval: 0,
                pausedAt: nil
            )
            appModel.sessionEngine.restore(from: snapshot, settings: appModel.settings)
        }
    }
}
