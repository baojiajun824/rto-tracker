//
//  CalendarRTOView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

struct CalendarRTOView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Start and End Date Pickers
                VStack(spacing: 8) {
                    HStack {
                        Text("Start Date:")
                            .font(.headline)
                        Spacer()
                        DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    HStack {
                        Text("End Date:")
                            .font(.headline)
                        Spacer()
                        DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal)

                // RTO Percentage Display
                let rtoPercentage = Double(viewModel.calculateRTOPercentage(
                    start: viewModel.startDate,
                    end: viewModel.endDate,
                    includeUnentered: settingsViewModel.includePendingDays
                )) ?? 0.0

                Text("RTO %: \(String(format: "%.2f", rtoPercentage))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(rtoPercentage >= settingsViewModel.rtoGoal ? .green : .red)

                // Additional Days Needed if below RTO Goal
                if settingsViewModel.includePendingDays && rtoPercentage < settingsViewModel.rtoGoal {
                    let additionalDaysNeeded = viewModel.calculateAdditionalDaysNeeded(
                        start: viewModel.startDate,
                        end: viewModel.endDate,
                        targetRTO: settingsViewModel.rtoGoal,
                        includeUnentered: settingsViewModel.includePendingDays
                    )
                    Text("You need \(additionalDaysNeeded) more days in office to meet your RTO Goal.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Day Counts
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        countItem(label: "Office", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).workFromOfficeCount, color: .green)
                        countItem(label: "Home", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).workFromHomeCount, color: .red)
                    }
                    HStack(spacing: 16) {
                        countItem(label: "Leave", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).leaveCount, color: .gray)
                        countItem(label: "Pending", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).unenteredCount, color: .blue)
                    }
                }

                Spacer()
            }
            .navigationTitle("RTO Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Helper function for Day Counts
    private func countItem(label: String, count: Int, color: Color) -> some View {
        VStack {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity) // Evenly distribute width
    }
}
