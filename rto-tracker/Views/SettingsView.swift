//
//  SettingsView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel
    @ObservedObject var reminderScheduler: ReminderScheduler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showClearConfirmation = false
    @State private var showNotificationPermissionAlert = false
    @State private var isRequestingNotificationPermission = false

    var body: some View {
        NavigationStack {
            Form {
                Section("RTO Goal") {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Text("\(Int(settingsViewModel.rtoGoal.rounded()))%")
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
                    Text("When enabled, pending weekdays count as non-office days in the percentage. Leave is always excluded.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Allow Weekend Office Credit", isOn: $settingsViewModel.includeWeekendOffice)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    Text("When enabled, weekends can be marked only as Office or cleared. They add office credit without increasing total days, so RTO may exceed 100%.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Reminder") {
                    Toggle(
                        "Missing Entry Reminder",
                        isOn: Binding(
                            get: { settingsViewModel.reminderEnabled },
                            set: setReminderEnabled
                        )
                    )
                    .disabled(isRequestingNotificationPermission)

                    if settingsViewModel.reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { settingsViewModel.reminderTime },
                                set: { settingsViewModel.reminderTime = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }

                    if reminderScheduler.authorizationStatus == .denied {
                        Button("Open Notification Settings") {
                            openNotificationSettings()
                        }
                    }

                    Text("When enabled, you’ll receive at most one reminder on weekdays when today has no entry.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
            .alert("Notifications Are Off", isPresented: $showNotificationPermissionAlert) {
                Button("Open Settings") {
                    openNotificationSettings()
                }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text("Allow notifications in iOS Settings to use missing-entry reminders.")
            }
            .task {
                await reminderScheduler.updateAuthorizationStatus()
            }
        }
    }

    private func setReminderEnabled(_ enabled: Bool) {
        guard enabled else {
            settingsViewModel.reminderEnabled = false
            reminderScheduler.refresh(
                enabled: false,
                reminderMinutes: settingsViewModel.reminderMinutes,
                selectedDays: calendarViewModel.selectedDays
            )
            return
        }

        isRequestingNotificationPermission = true
        Task {
            let granted = await reminderScheduler.requestAuthorization()
            isRequestingNotificationPermission = false

            guard granted else {
                settingsViewModel.reminderEnabled = false
                showNotificationPermissionAlert = true
                return
            }

            settingsViewModel.reminderEnabled = true
            reminderScheduler.refresh(
                enabled: true,
                reminderMinutes: settingsViewModel.reminderMinutes,
                selectedDays: calendarViewModel.selectedDays
            )
        }
    }

    private func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }
}
