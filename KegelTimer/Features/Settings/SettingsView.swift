import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appModel: AppModel

    private let countdownOptions = [0, 3, 5]

    var body: some View {
        ZStack {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    settingsCard(title: "Difficulty") {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Training Mode")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Text("Choose the default intensity for new sessions.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.mutedInk)

                            VStack(spacing: 12) {
                                ForEach(WorkoutDifficulty.allCases) { difficulty in
                                    difficultyRow(difficulty)
                                }
                            }
                        }
                    }

                    settingsCard(title: "Session") {
                        toggleRow(
                            title: "Sound",
                            subtitle: "Play audio cues during transitions",
                            isOn: Binding(
                                get: { appModel.settings.soundEnabled },
                                set: appModel.setSoundEnabled
                            )
                        )

                        divider

                        toggleRow(
                            title: "Haptics",
                            subtitle: "Vibrate on phase changes when available",
                            isOn: Binding(
                                get: { appModel.settings.hapticsEnabled },
                                set: appModel.setHapticsEnabled
                            )
                        )

                        divider

                        toggleRow(
                            title: "Keep Screen Awake",
                            subtitle: "Prevent dimming while a session is running",
                            isOn: Binding(
                                get: { appModel.settings.keepScreenAwake },
                                set: appModel.setKeepScreenAwake
                            )
                        )
                    }

                    settingsCard(title: "Start") {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Countdown")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Text("Choose how long the app waits before a session starts.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.mutedInk)

                            Picker("Countdown", selection: startCountdownBinding) {
                                ForEach(countdownOptions, id: \.self) { seconds in
                                    Text(countdownLabel(for: seconds))
                                        .tag(seconds)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    settingsCard(title: "Reminders") {
                        NavigationLink {
                            RemindersView(showsCloseButton: false)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sessions Reminders")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)

                                    Text(reminderSummary)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppTheme.mutedInk)
                                }

                                Spacer(minLength: 12)

                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(hasEnabledReminders ? AppTheme.accent : AppTheme.mutedInk)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppTheme.mutedInk)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    settingsCard(title: "Monetization") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Status")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)

                                    Text(appModel.hasRemovedAds ? "Ad-free unlocked" : "Ads enabled")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppTheme.mutedInk)
                                }

                                Spacer(minLength: 12)

                                Image(systemName: appModel.hasRemovedAds ? "checkmark.seal.fill" : "megaphone.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(appModel.hasRemovedAds ? AppTheme.accent : AppTheme.mutedInk)
                            }

                            divider

                            Button {
                                Task {
                                    await appModel.purchaseRemoveAds()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(appModel.removeAdsCTA)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundStyle(appModel.hasRemovedAds ? AppTheme.mutedInk : AppTheme.ink)

                                        Text(appModel.hasRemovedAds
                                             ? "This one-time purchase is already active on this device."
                                             : "One-time purchase to permanently remove banner ads.")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(AppTheme.mutedInk)
                                    }

                                    Spacer(minLength: 12)

                                    if appModel.isStoreProcessing {
                                        ProgressView()
                                            .tint(AppTheme.accent)
                                    } else {
                                        Image(systemName: appModel.hasRemovedAds ? "checkmark.circle.fill" : "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(appModel.hasRemovedAds ? AppTheme.accent : AppTheme.mutedInk)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(appModel.hasRemovedAds || appModel.isStoreProcessing)

                            divider

                            Button {
                                Task {
                                    await appModel.restorePurchases()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Restore Purchases")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundStyle(AppTheme.ink)

                                        Text("Use this if you already bought Remove Ads on another device.")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(AppTheme.mutedInk)
                                    }

                                    Spacer(minLength: 12)

                                    if appModel.isStoreProcessing {
                                        ProgressView()
                                            .tint(AppTheme.accent)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(AppTheme.mutedInk)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(appModel.isStoreProcessing)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert(item: $appModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var startCountdownBinding: Binding<Int> {
        Binding(
            get: { appModel.settings.startCountdownDuration },
            set: appModel.setStartCountdownDuration
        )
    }

    private var hasEnabledReminders: Bool {
        appModel.settings.reminderSchedules.contains { $0.isEnabled }
    }

    private var reminderSummary: String {
        let scheduleCount = appModel.settings.reminderSchedules.count

        guard scheduleCount > 0 else {
            return "Set a recurring workout schedule."
        }

        if hasEnabledReminders {
            return scheduleCount == 1 ? "1 schedule active" : "\(scheduleCount) schedules saved"
        }

        return scheduleCount == 1 ? "1 schedule saved but turned off" : "\(scheduleCount) schedules saved but turned off"
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
    }

    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(AppTheme.mutedInk)

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AppTheme.panel.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            Spacer(minLength: 12)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
    }

    private func difficultyRow(_ difficulty: WorkoutDifficulty) -> some View {
        let isSelected = appModel.settings.difficulty == difficulty

        return Button {
            appModel.setDifficulty(difficulty)
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    Text(difficulty.subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk)
                }

                Spacer(minLength: 12)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? AppTheme.accent : AppTheme.mutedInk)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? AppTheme.canvasSecondary : .white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? AppTheme.accent.opacity(0.45) : .white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func countdownLabel(for seconds: Int) -> String {
        seconds == 0 ? "Off" : "\(seconds)s"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppModel())
    }
}
