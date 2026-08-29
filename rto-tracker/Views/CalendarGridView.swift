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

    private struct DayCell: Identifiable {
        enum ID: Hashable {
            case placeholder(LocalDay, Int)
            case day(LocalDay)
        }

        let id: ID
        let date: Date?
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7),
                spacing: 4
            ) {
                ForEach(generateDays(for: currentDate)) { cell in
                    if let date = cell.date {
                        let isWeekend = Calendar.current.isDateInWeekend(date)
                        CalendarDayView(
                            date: date,
                            dayType: viewModel.dayType(for: date),
                            isInteractable: !isWeekend,
                            action: {
                                viewModel.toggleDayType(for: date)
                            },
                            selectionAction: { type in
                                viewModel.setDayType(type, for: date)
                            }
                        )
                    } else {
                        Color.clear
                            .frame(width: 44, height: 44)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstIndex = max(0, min(calendar.firstWeekday - 1, symbols.count - 1))
        return (0..<symbols.count).map { symbols[(firstIndex + $0) % symbols.count] }
    }

    private func generateDays(for date: Date) -> [DayCell] {
        let calendar = Calendar.current
        guard
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: date)
            ),
            let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)
        else {
            return []
        }

        let month = LocalDay(firstDayOfMonth, calendar: calendar)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let weekdayOffset = (firstWeekday - calendar.firstWeekday + 7) % 7
        let leadingCells = (0..<weekdayOffset).map { index in
            DayCell(id: .placeholder(month, index), date: nil)
        }
        let monthDays = daysInMonth.compactMap { day -> DayCell? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) else {
                return nil
            }
            return DayCell(id: .day(LocalDay(date, calendar: calendar)), date: date)
        }

        return leadingCells + monthDays
    }
}
