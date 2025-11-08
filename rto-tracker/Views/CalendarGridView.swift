//
//  CalendarGridView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var currentDate: Date
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: height * 0.01) {
            // Weekday Headers
            HStack {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: height * 0.01) {
                ForEach(Array(generateDays(for: currentDate).enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        let isWeekend = Calendar.current.isDateInWeekend(date)
                        CalendarDayView(date: date, dayType: viewModel.selectedDays[date], isInteractable: !isWeekend)
                            .onTapGesture {
                                if !isWeekend {
                                    viewModel.toggleDayType(for: date)
                                }
                            }
                            .frame(height: height * 0.05)
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: height * 0.05)
                    }
                }
            }
        }
    }

    private func generateDays(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let weekdayOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!

        let leadingEmptyCells: [Date?] = Array(repeating: nil, count: weekdayOffset)
        let monthDays = daysInMonth.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }

        return leadingEmptyCells + monthDays
    }
}
