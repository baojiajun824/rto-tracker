//
//  RTOStatusView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct RTOStatusView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        let rtoPercentage = Double(viewModel.calculateRTOPercentage(
            start: viewModel.startDate,
            end: viewModel.endDate,
            includeUnentered: settingsViewModel.includePendingDays
        )) ?? 0.0

        VStack(spacing: height * 0.02) {
            // RTO %
            Text("RTO %: \(String(format: "%.2f", rtoPercentage))%")
                .font(.system(size: width * 0.06))
                .fontWeight(.semibold)
                .foregroundColor(rtoPercentage >= settingsViewModel.rtoGoal ? .green : .red)

            // Additional Days Needed
            if settingsViewModel.includePendingDays && rtoPercentage < settingsViewModel.rtoGoal {
                let additionalDaysNeeded = viewModel.calculateAdditionalDaysNeeded(
                    start: viewModel.startDate,
                    end: viewModel.endDate,
                    targetRTO: settingsViewModel.rtoGoal,
                    includeUnentered: settingsViewModel.includePendingDays
                )

                Text("To meet your RTO Goal, you need \(additionalDaysNeeded) more days in office.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Day Counts in One Line
            HStack(spacing: width * 0.05) {
                countItem(label: "Office", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).workFromOfficeCount, color: .green, width: width)
                countItem(label: "Home", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).workFromHomeCount, color: .red, width: width)
                countItem(label: "Leave", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).leaveCount, color: .gray, width: width)
                countItem(label: "Pending", count: viewModel.calculateDayCounts(start: viewModel.startDate, end: viewModel.endDate).unenteredCount, color: .blue, width: width)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // Helper function for displaying counts
    private func countItem(label: String, count: Int, color: Color, width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(color)
                .lineLimit(1) // Prevent wrapping
                .minimumScaleFactor(0.8) // Scale text if space is limited
        }
        .frame(maxWidth: width * 0.22) // Dynamically allocate space for each item
    }
}
