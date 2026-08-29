//
//  rto_trackerApp.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

@main
struct RTOApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            CalendarView()
                .environmentObject(settingsViewModel)
        }
    }
}
