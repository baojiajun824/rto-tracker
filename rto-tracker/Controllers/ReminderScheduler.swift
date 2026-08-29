import Foundation
import UserNotifications

enum ReminderSchedule {
    static func fireDates(
        now: Date,
        reminderMinutes: Int,
        selectedDays: [LocalDay: DayType],
        horizonDays: Int = 60,
        limit: Int = 45,
        calendar: Calendar = .current
    ) -> [Date] {
        let minutes = min(max(reminderMinutes, 0), (24 * 60) - 1)
        let hour = minutes / 60
        let minute = minutes % 60
        let startOfToday = calendar.startOfDay(for: now)
        var dates: [Date] = []

        for offset in 0..<horizonDays where dates.count < limit {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
                continue
            }
            guard !calendar.isDateInWeekend(day) else {
                continue
            }
            guard selectedDays[LocalDay(day, calendar: calendar)] == nil else {
                continue
            }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = hour
            components.minute = minute
            guard let fireDate = calendar.date(from: components), fireDate > now else {
                continue
            }
            dates.append(fireDate)
        }

        return dates
    }
}

@MainActor
final class ReminderScheduler: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private static let identifierPrefix = "rto-entry-reminder-"

    private let notificationCenter: UNUserNotificationCenter
    private var refreshTask: Task<Void, Never>?

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    var notificationsAreAvailable: Bool {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }

    func updateAuthorizationStatus() async {
        authorizationStatus = await notificationCenter.notificationSettings().authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        await updateAuthorizationStatus()

        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
                await updateAuthorizationStatus()
                return granted
            } catch {
                await updateAuthorizationStatus()
                return false
            }
        @unknown default:
            return false
        }
    }

    func refresh(
        enabled: Bool,
        reminderMinutes: Int,
        selectedDays: [LocalDay: DayType],
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else {
                return
            }
            await self.performRefresh(
                enabled: enabled,
                reminderMinutes: reminderMinutes,
                selectedDays: selectedDays,
                now: now,
                calendar: calendar
            )
        }
    }

    private func performRefresh(
        enabled: Bool,
        reminderMinutes: Int,
        selectedDays: [LocalDay: DayType],
        now: Date,
        calendar: Calendar
    ) async {
        await updateAuthorizationStatus()
        guard !Task.isCancelled else {
            return
        }

        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let managedIdentifiers = pendingRequests
            .map(\.identifier)
            .filter { $0.hasPrefix(Self.identifierPrefix) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: managedIdentifiers)

        let enteredIdentifiers = selectedDays.keys.map(Self.identifier)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: enteredIdentifiers)

        guard enabled, notificationsAreAvailable, !Task.isCancelled else {
            return
        }

        let fireDates = ReminderSchedule.fireDates(
            now: now,
            reminderMinutes: reminderMinutes,
            selectedDays: selectedDays,
            calendar: calendar
        )

        for fireDate in fireDates {
            guard !Task.isCancelled else {
                return
            }

            let day = LocalDay(fireDate, calendar: calendar)
            let content = UNMutableNotificationContent()
            content.title = "RTO Tracker"
            content.body = "Remember to update today’s work entry."
            content.sound = .default

            let dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: Self.identifier(for: day),
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                return
            }
        }
    }

    private static func identifier(for day: LocalDay) -> String {
        "\(identifierPrefix)\(day.year)-\(day.month)-\(day.day)"
    }
}
