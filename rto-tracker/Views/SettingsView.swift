//
//  SettingsView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("RTO Goal") {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Text("\(Int(settingsViewModel.rtoGoal))%")
                    }
                    Slider(
                        value: $settingsViewModel.rtoGoal,
                        in: 0...100,
                        step: 1
                    )
                }

                Section("RTO Calculation") {
                    Toggle("Include Pending Days", isOn: $settingsViewModel.includePendingDays)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    Text("When enabled, pending weekdays count as non-office days in the percentage. Leave and weekends are always excluded.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button("Reset Settings") {
                        settingsViewModel.resetToDefaults()
                    }
                    Button("Clear Calendar Data", role: .destructive) {
                        showClearConfirmation = true
                    }
                } footer: {
                    Text("Calendar entries and settings stay on this device and are not uploaded.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear Calendar Data?", isPresented: $showClearConfirmation) {
                Button("Clear", role: .destructive) {
                    calendarViewModel.clearCalendarData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes every Office, Home, and Leave entry on this device. This action cannot be undone.")
            }
        }
    }
}
