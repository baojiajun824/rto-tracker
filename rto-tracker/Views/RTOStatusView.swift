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
        VStack(spacing: max(height * 0.015, 10)) {
            if let summary = viewModel.summary(
                targetRTO: settingsViewModel.rtoGoal,
                includePendingDays: settingsViewModel.includePendingDays,
                includeWeekendOffice: settingsViewModel.includeWeekendOffice
            ) {
                percentageStatus(summary)
                recommendation(summary)
                weekendCreditNote(summary)

                HStack(spacing: max(width * 0.025, 6)) {
                    countItem(
                        label: "Office",
                        count: summary.counts.workFromOfficeCount,
                        color: .green,
                        systemImage: DayType.workFromOffice.systemImage,
                        width: width
                    )
                    countItem(
                        label: "Home",
                        count: summary.counts.workFromHomeCount,
                        color: .red,
                        systemImage: DayType.workFromHome.systemImage,
                        width: width
                    )
                    countItem(
                        label: "Leave",
                        count: summary.counts.leaveCount,
                        color: .gray,
                        systemImage: DayType.leave.systemImage,
                        width: width
                    )
                    countItem(
                        label: "Pending",
                        count: summary.counts.unenteredCount,
                        color: .blue,
                        systemImage: DayType.default.systemImage,
                        width: width
                    )
                }
                .frame(maxWidth: .infinity)
            } else {
                Label("Choose a valid date range to calculate RTO.", systemImage: "calendar.badge.exclamationmark")
                    .font(.headline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private func weekendCreditNote(_ summary: RTOSummary) -> some View {
        if summary.counts.weekendOfficeCount > 0 {
            Text(
                "\(summary.counts.weekendOfficeCount) weekend "
                + (summary.counts.weekendOfficeCount == 1 ? "office day counts" : "office days count")
                + " as credit without increasing total days."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func percentageStatus(_ summary: RTOSummary) -> some View {
        if let percentage = summary.percentage,
           let formattedPercentage = summary.formattedPercentage() {
            let meetsGoal = percentage >= settingsViewModel.rtoGoal
            Label(
                "RTO: \(formattedPercentage)%",
                systemImage: meetsGoal ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
            )
            .font(.title2.weight(.semibold))
            .foregroundStyle(meetsGoal ? .green : .red)
            .accessibilityLabel(
                "Return to office percentage \(formattedPercentage) percent. Goal \(meetsGoal ? "met" : "not met")."
            )
        } else {
            Label("No entered workdays", systemImage: "minus.circle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func recommendation(_ summary: RTOSummary) -> some View {
        if summary.additionalOfficeDaysNeeded > 0 {
            if summary.canMeetGoalWithPendingDays {
                Text(
                    "Mark \(summary.additionalOfficeDaysNeeded) more pending "
                    + (summary.additionalOfficeDaysNeeded == 1 ? "day" : "days")
                    + " as Office to meet your goal."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            } else {
                Text("The goal cannot be reached with the pending days in this range.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func countItem(
        label: String,
        count: Int,
        color: Color,
        systemImage: String,
        width: CGFloat
    ) -> some View {
        VStack(spacing: 4) {
            Label("\(count)", systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(color)
                .labelStyle(.titleAndIcon)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: width * 0.23)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(count)")
    }
}
