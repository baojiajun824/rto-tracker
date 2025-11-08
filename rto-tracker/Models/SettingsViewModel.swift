//
//  SettingsViewModel.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("rtoGoal") var rtoGoal: Double = 50.0 // Default is 50%
    @AppStorage("includePendingDays") var includePendingDays: Bool = false // Default is false

    func resetToDefaults() {
        rtoGoal = 50.0
        includePendingDays = false
    }
}
