import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.ink)

            VStack(spacing: 0) {
                Toggle(
                    "Sound cues",
                    isOn: Binding(
                        get: { appModel.settings.soundEnabled },
                        set: { appModel.setSoundEnabled($0) }
                    )
                )
                .padding(.horizontal, 18)
                .padding(.vertical, 16)

                Divider()
                    .padding(.leading, 18)

                Toggle(
                    "Haptic cues",
                    isOn: Binding(
                        get: { appModel.settings.hapticsEnabled },
                        set: { appModel.setHapticsEnabled($0) }
                    )
                )
                .padding(.horizontal, 18)
                .padding(.vertical, 16)

                Divider()
                    .padding(.leading, 18)

                Toggle(
                    "Keep screen awake",
                    isOn: Binding(
                        get: { appModel.settings.keepScreenAwake },
                        set: { appModel.setKeepScreenAwake($0) }
                    )
                )
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.92))
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Use this app as a pacing tool, not medical advice.")
                    .font(.body)
                    .foregroundStyle(AppTheme.ink)
                Text("If you feel pain or discomfort, stop and consult a qualified clinician.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.ink.opacity(0.65))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.72))
            )
        }
    }
}
