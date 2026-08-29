//
//  SettingsViewModel.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var rtoGoal: Double {
        didSet {
            defaults.set(rtoGoal, forKey: Keys.rtoGoal)
        }
    }

    @Published var includePendingDays: Bool {
        didSet {
            defaults.set(includePendingDays, forKey: Keys.includePendingDays)
        }
    }

    @Published var reminderEnabled: Bool {
        didSet {
            defaults.set(reminderEnabled, forKey: Keys.reminderEnabled)
        }
    }

    @Published private(set) var reminderMinutes: Int {
        didSet {
            defaults.set(reminderMinutes, forKey: Keys.reminderMinutes)
        }
    }

    var reminderTime: Date {
        get {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            return calendar.date(
                byAdding: .minute,
                value: reminderMinutes,
                to: startOfToday
            ) ?? startOfToday
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            guard let hour = components.hour, let minute = components.minute else {
                return
            }
            reminderMinutes = (hour * 60) + minute
        }
    }

    private enum Keys {
        static let rtoGoal = "rtoGoal"
        static let includePendingDays = "includePendingDays"
        static let reminderEnabled = "reminderEnabled"
        static let reminderMinutes = "reminderMinutes"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        rtoGoal = defaults.object(forKey: Keys.rtoGoal) as? Double ?? 50
        includePendingDays = defaults.object(forKey: Keys.includePendingDays) as? Bool ?? false
        reminderEnabled = defaults.object(forKey: Keys.reminderEnabled) == nil
            ? false
            : defaults.bool(forKey: Keys.reminderEnabled)
        let storedMinutes = defaults.object(forKey: Keys.reminderMinutes) == nil
            ? 15 * 60
            : defaults.integer(forKey: Keys.reminderMinutes)
        reminderMinutes = min(max(storedMinutes, 0), (24 * 60) - 1)
    }

    func resetToDefaults() {
        rtoGoal = 50
        includePendingDays = false
        reminderEnabled = false
        reminderMinutes = 15 * 60
    }
}
