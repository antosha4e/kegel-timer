import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var isEditingCustomRoutine = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 14) {
                    Text("Built-In Sessions")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)

                    ForEach(appModel.presets) { preset in
                        WorkoutCard(
                            title: preset.name,
                            subtitle: preset.subtitle,
                            detail: "\(preset.squeezeSeconds)s squeeze • \(preset.relaxSeconds)s relax • \(preset.repetitions) reps",
                            buttonTitle: "Start"
                        ) {
                            appModel.startPreset(preset)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Custom Routine")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)

                    WorkoutCard(
                        title: appModel.customRoutine.name,
                        subtitle: "Your saved routine",
                        detail: "\(appModel.customRoutine.squeezeSeconds)s squeeze • \(appModel.customRoutine.relaxSeconds)s relax • \(appModel.customRoutine.repetitions) reps",
                        buttonTitle: "Start"
                    ) {
                        appModel.startCustomRoutine()
                    }

                    Button("Edit Custom Routine") {
                        isEditingCustomRoutine = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                }

                SettingsView()
            }
            .padding(20)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .sheet(isPresented: $isEditingCustomRoutine) {
            CustomRoutineEditorView(routine: appModel.customRoutine)
            .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiet strength, deliberate rhythm.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            Text("Pick a routine and let the timer drive the pace. The session keeps accurate timing even if you leave the app.")
                .font(.body)
                .foregroundStyle(AppTheme.ink.opacity(0.72))

            HStack(spacing: 12) {
                StatChip(title: "Fast Start", value: "3 presets")
                StatChip(title: "Custom", value: "1 saved")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.heroGradient)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.22))
                .frame(width: 120, height: 120)
                .offset(x: 24, y: -28)
        }
    }
}

private struct WorkoutCard: View {
    let title: String
    let subtitle: String
    let detail: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.ink.opacity(0.7))

            Text(detail)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppTheme.accent)

            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.92))
        )
    }
}

private struct StatChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.72), in: Capsule())
    }
}
