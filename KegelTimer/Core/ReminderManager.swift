import Foundation
import UserNotifications

enum ReminderManagerError: LocalizedError {
    case notificationsDenied

    var errorDescription: String? {
        switch self {
        case .notificationsDenied:
            return "Notifications are disabled. Enable them in Settings to receive reminders."
        }
    }
}

struct ReminderAuthorizationStatus {
    let isAuthorized: Bool
    let needsSettingsPrompt: Bool
}

final class ReminderManager {
    private let center: UNUserNotificationCenter
    private let identifierPrefix = "workout-reminder-"

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func syncSchedules(_ schedules: [ReminderSchedule]) async throws -> ReminderAuthorizationStatus {
        let pendingRequests = await center.pendingNotificationRequests()
        let reminderIdentifiers = pendingRequests
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }

        if !reminderIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        }

        let enabledSchedules = schedules.filter(\.isEnabled)
        guard !enabledSchedules.isEmpty else {
            return ReminderAuthorizationStatus(isAuthorized: true, needsSettingsPrompt: false)
        }

        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined:
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else {
                throw ReminderManagerError.notificationsDenied
            }
        case .denied:
            throw ReminderManagerError.notificationsDenied
        @unknown default:
            throw ReminderManagerError.notificationsDenied
        }

        for schedule in enabledSchedules {
            try await addRequests(for: schedule)
        }

        return ReminderAuthorizationStatus(
            isAuthorized: true,
            needsSettingsPrompt: settings.authorizationStatus == .denied
        )
    }

    private func addRequests(for schedule: ReminderSchedule) async throws {
        for weekday in schedule.weekdays {
            let content = UNMutableNotificationContent()
            content.title = "Kegel Timer"
            content.body = "Time for your session."
            content.sound = .default

            var components = DateComponents()
            components.weekday = weekday.rawValue
            components.hour = schedule.hour
            components.minute = schedule.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: identifier(for: schedule.id, weekday: weekday),
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        }
    }

    private func identifier(for id: UUID, weekday: ReminderWeekday) -> String {
        "\(identifierPrefix)\(id.uuidString)-\(weekday.rawValue)"
    }
}

private extension UNUserNotificationCenter {
    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }
}
