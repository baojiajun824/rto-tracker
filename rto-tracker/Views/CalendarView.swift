//
//  CalendarView.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showSettings = false
    @State private var currentDate = Date()

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let safeAreaInsets = geometry.safeAreaInsets

            VStack {
                ScrollView {
                    VStack(spacing: height * 0.02) {
                        // Fancy Title
                        CalendarTitleView()

                        // Start Date and End Date
                        DatePickerView(viewModel: viewModel, width: width)

                        // RTO % and Status
                        RTOStatusView(viewModel: viewModel, settingsViewModel: _settingsViewModel, width: width, height: height)

                        // Month Navigation Buttons
                        monthNavigation(width: width)

                        // Calendar Grid
                        CalendarGridView(viewModel: viewModel, currentDate: $currentDate, width: width, height: height)

                        // Legend
                        LegendView()
                            .padding(.top, height * 0.02)

                        // Settings Button
                        SettingsButtonView(showSettings: $showSettings)
                            .padding(.top, height * 0.02)
                    }
                    .padding(.vertical, safeAreaInsets.top > 0 ? safeAreaInsets.top : height * 0.02) // Consider safe area
                    .padding(.bottom, safeAreaInsets.bottom) // Avoid home indicator overlap
                }
            }
            .edgesIgnoringSafeArea([.horizontal]) // Ensure full horizontal use of the screen
        }
    }

    /// Month navigation buttons for navigating between months
    private func monthNavigation(width: CGFloat) -> some View {
        HStack {
            Button(action: { adjustMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            Spacer()
            Text(monthYearString(for: currentDate))
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Button(action: { adjustMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .padding(.horizontal, width * 0.05)
    }

    /// Adjust the calendar to a previous or next month
    private func adjustMonth(by value: Int) {
        currentDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
    }

    /// Generate the string for the current month and year
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
