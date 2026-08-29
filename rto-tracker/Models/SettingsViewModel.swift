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

    private enum Keys {
        static let rtoGoal = "rtoGoal"
        static let includePendingDays = "includePendingDays"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        rtoGoal = defaults.object(forKey: Keys.rtoGoal) as? Double ?? 50
        includePendingDays = defaults.object(forKey: Keys.includePendingDays) as? Bool ?? false
    }

    func resetToDefaults() {
        rtoGoal = 50
        includePendingDays = false
    }
}
