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

            ScrollView {
                VStack(spacing: max(height * 0.02, 12)) {
                    CalendarTitleView()
                    DatePickerView(viewModel: viewModel, width: width)
                    RTOStatusView(viewModel: viewModel, width: width, height: height)
                    monthNavigation(width: width)
                    CalendarGridView(
                        viewModel: viewModel,
                        currentDate: $currentDate
                    )
                    LegendView()
                    SettingsButtonView(
                        showSettings: $showSettings,
                        calendarViewModel: viewModel
                    )
                }
                .padding(.top, safeAreaInsets.top > 0 ? safeAreaInsets.top : 16)
                .padding(.bottom, max(safeAreaInsets.bottom, 16))
            }
            .ignoresSafeArea(.container, edges: .horizontal)
        }
        .alert(
            "Calendar Data Issue",
            isPresented: Binding(
                get: { viewModel.persistenceErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissPersistenceError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.dismissPersistenceError()
            }
        } message: {
            Text(viewModel.persistenceErrorMessage ?? "")
        }
    }

    /// Month navigation buttons for navigating between months
    private func monthNavigation(width: CGFloat) -> some View {
        HStack {
            Button(action: { adjustMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Previous month")
            Spacer()
            VStack(spacing: 2) {
                Text(monthYearString(for: currentDate))
                    .font(.headline)
                    .fontWeight(.bold)
                Button("Today") {
                    withAnimation {
                        currentDate = Date()
                    }
                }
                .font(.caption.weight(.semibold))
                .disabled(Calendar.current.isDate(currentDate, equalTo: Date(), toGranularity: .month))
                .accessibilityLabel("Show current month")
            }
            Spacer()
            Button(action: { adjustMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Next month")
        }
        .padding(.horizontal, width * 0.05)
    }

    /// Adjust the calendar to a previous or next month
    private func adjustMonth(by value: Int) {
        currentDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
    }

    /// Generate the string for the current month and year
    private func monthYearString(for date: Date) -> String {
        date.formatted(.dateTime.month(.wide).year())
    }
}
