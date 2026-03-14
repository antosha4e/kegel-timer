import SwiftUI

struct ActiveSessionView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine

    var body: some View {
        Group {
            if let state = sessionEngine.state {
                if state.status == .completed {
                    completionView(state: state)
                } else {
                    activeView(state: state)
                }
            } else {
                Color.clear
            }
        }
        .background(backgroundGradient.ignoresSafeArea())
    }

    private var backgroundGradient: LinearGradient {
        guard let phase = sessionEngine.state?.phase else {
            return AppTheme.canvasGradient
        }
        return phase == .squeeze ? AppTheme.squeezeGradient : AppTheme.relaxGradient
    }

    private func activeView(state: SessionState) -> some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(.white.opacity(0.3))
                .frame(width: 54, height: 6)
                .padding(.top, 12)

            VStack(spacing: 10) {
                Text(state.routine.name)
                    .font(.headline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))

                Text(state.phase.title)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(state.phase.coachingLine)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.78))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Text(timeString(from: state.secondsRemainingInPhase))
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(state.progressText)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.84))
            }

            ProgressView(value: state.progress)
                .tint(.white)
                .scaleEffect(x: 1, y: 1.6)
                .padding(.horizontal, 8)

            sessionMetrics(state: state)

            Spacer(minLength: 12)

            HStack(spacing: 12) {
                Button(state.isPaused ? "Resume" : "Pause") {
                    if state.isPaused {
                        sessionEngine.resume(settings: appModel.settings)
                    } else {
                        sessionEngine.pause(settings: appModel.settings)
                    }
                }
                .buttonStyle(SessionActionButtonStyle(fill: .white, foreground: AppTheme.ink))

                Button("Cancel") {
                    sessionEngine.cancel()
                }
                .buttonStyle(SessionActionButtonStyle(fill: .white.opacity(0.18), foreground: .white))
            }
            .padding(.bottom, 28)
        }
        .padding(.horizontal, 24)
    }

    private func completionView(state: SessionState) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white)

            Text("Session Complete")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("\(state.routine.name) finished. Total time: \(timeString(from: state.totalDuration)).")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)

            Button("Close") {
                appModel.finishCompletedSession()
            }
            .buttonStyle(SessionActionButtonStyle(fill: .white, foreground: AppTheme.ink))
        }
        .padding(28)
    }

    private func sessionMetrics(state: SessionState) -> some View {
        HStack(spacing: 12) {
            SessionMetric(title: "Elapsed", value: timeString(from: state.elapsedSeconds))
            SessionMetric(title: "Phase", value: "\(state.phaseDuration)s")
            SessionMetric(title: "Total", value: timeString(from: state.totalDuration))
        }
    }

    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct SessionMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct SessionActionButtonStyle: ButtonStyle {
    let fill: Color
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(fill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .opacity(configuration.isPressed ? 0.84 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
