import SwiftUI

struct RemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appModel: AppModel

    let showsCloseButton: Bool

    @State private var editorState: ReminderEditorState?

    init(showsCloseButton: Bool = true) {
        self.showsCloseButton = showsCloseButton
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    heroSection
                        .padding(.top, 110)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reminder Schedule")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        addScheduleButton

                        if appModel.settings.reminderSchedules.isEmpty {
                            emptyStateCard
                        } else {
                            scheduleList
                        }
                    }

                    Spacer(minLength: 120)

                    tipCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }

            if showsCloseButton {
                closeButton
                    .padding(.top, 56)
                    .padding(.trailing, 24)
            }
        }
        .sheet(item: $editorState) { state in
            ReminderEditorSheet(
                title: state.schedule == nil ? "Add Schedule" : "Edit Schedule",
                initialSchedule: state.schedule
            ) { schedule in
                if state.schedule == nil {
                    appModel.addReminderSchedule(schedule)
                } else {
                    appModel.updateReminderSchedule(schedule)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroSection: some View {
        VStack(spacing: 18) {
            Text("Set reminders")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Create a schedule & get workout reminders that'll make your training process consistent")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity)
    }

    private var addScheduleButton: some View {
        Button {
            editorState = ReminderEditorState(schedule: nil)
        } label: {
            HStack {
                Text("Add Schedule")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer(minLength: 12)

                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.panel.opacity(0.98))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.04), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No reminders yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text("Add a schedule to keep your progress consistent throughout the week.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.canvasSecondary.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
    }

    private var scheduleList: some View {
        VStack(spacing: 14) {
            ForEach(appModel.settings.reminderSchedules) { schedule in
                scheduleCard(for: schedule)
            }
        }
    }

    private func scheduleCard(for schedule: ReminderSchedule) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(timeFormatter.string(from: schedule.timeDate))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(schedule.weekdaySummary)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: scheduleEnabledBinding(for: schedule))
                .labelsHidden()
                .tint(AppTheme.accent)

            Button(role: .destructive) {
                appModel.removeReminderSchedule(id: schedule.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.04))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.panel.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture {
            editorState = ReminderEditorState(schedule: schedule)
        }
    }

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(red: 0.05, green: 0.85, blue: 0.58))
                    .frame(width: 18, height: 18)

                Text("PRO TIP:")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.panelSecondary.opacity(0.96))
            )

            Text("You can set multiple schedules that suit you best. For example, one for weekdays & one for weekends.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(6)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppTheme.panel.opacity(0.96))
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(AppTheme.mutedInk)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }

    private func scheduleEnabledBinding(for schedule: ReminderSchedule) -> Binding<Bool> {
        Binding(
            get: { schedule.isEnabled },
            set: { isEnabled in
                var updatedSchedule = schedule
                updatedSchedule.isEnabled = isEnabled
                appModel.updateReminderSchedule(updatedSchedule)
            }
        )
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

private struct ReminderEditorState: Identifiable {
    let id: UUID
    let schedule: ReminderSchedule?

    init(schedule: ReminderSchedule?) {
        self.id = schedule?.id ?? UUID()
        self.schedule = schedule
    }
}

private struct ReminderEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let initialSchedule: ReminderSchedule?
    let onSave: (ReminderSchedule) -> Void

    @State private var selectedTime: Date
    @State private var selectedWeekdays: Set<ReminderWeekday>
    @State private var isEnabled: Bool

    init(title: String, initialSchedule: ReminderSchedule?, onSave: @escaping (ReminderSchedule) -> Void) {
        self.title = title
        self.initialSchedule = initialSchedule
        self.onSave = onSave

        let schedule = initialSchedule ?? .suggested
        _selectedTime = State(initialValue: schedule.timeDate)
        _selectedWeekdays = State(initialValue: Set(schedule.weekdays))
        _isEnabled = State(initialValue: schedule.isEnabled)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker(
                        "Reminder Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Repeat") {
                    weekdayGrid
                }

                Section {
                    Toggle("Enabled", isOn: $isEnabled)
                        .tint(AppTheme.accent)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.canvasGradient.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(makeSchedule())
                        dismiss()
                    }
                    .disabled(selectedWeekdays.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var weekdayGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ForEach(ReminderWeekday.allCases) { day in
                Button {
                    toggle(day)
                } label: {
                    Text(day.shortTitle)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(selectedWeekdays.contains(day) ? .white : AppTheme.mutedInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedWeekdays.contains(day) ? AppTheme.accent.opacity(0.92) : AppTheme.panel.opacity(0.9))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .listRowBackground(Color.clear)
    }

    private func toggle(_ day: ReminderWeekday) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }

    private func makeSchedule() -> ReminderSchedule {
        ReminderSchedule(
            id: initialSchedule?.id ?? UUID(),
            time: selectedTime,
            weekdays: Array(selectedWeekdays).sorted { $0.rawValue < $1.rawValue },
            isEnabled: isEnabled
        )
    }
}

#Preview {
    RemindersView()
        .environmentObject(AppModel())
}
