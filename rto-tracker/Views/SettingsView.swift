//
//  SettingsView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                // RTO Goal Section
                Section(header: Text("RTO Goal")) {
                    HStack {
                        Text("RTO Goal:")
                        Spacer()
                        Text("\(Int(settingsViewModel.rtoGoal))%")
                    }
                    Slider(
                        value: $settingsViewModel.rtoGoal,
                        in: 0...100,
                        step: 1
                    )
                }

                // RTO Calculation Section
                Section(header: Text("RTO Calculation")) {
                    Toggle("Include Pending Days", isOn: $settingsViewModel.includePendingDays)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    Text("If enabled, pending days are considered as Work from Home.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Reset to Defaults Section
                Section {
                    Button(action: {
                        settingsViewModel.resetToDefaults()
                    }) {
                        Text("Reset to Defaults")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
