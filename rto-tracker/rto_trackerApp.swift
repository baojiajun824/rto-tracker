//
//  rto_trackerApp.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

@main
struct RTOApp: App { // Replace "RTOApp" with your app's name
    @StateObject private var settingsViewModel = SettingsViewModel() // Instantiate the SettingsViewModel

    var body: some Scene {
        WindowGroup {
            CalendarView()
                .environmentObject(settingsViewModel) // Share the SettingsViewModel across all views
        }
    }
}
