//
//  DatePickerView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct DatePickerView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let width: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: width * 0.08) {
                VStack {
                    Text("Start Date")
                        .font(.headline)
                    DatePicker(
                        "Start Date",
                        selection: $viewModel.startDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .accessibilityLabel("Start Date")
                }
                VStack {
                    Text("End Date")
                        .font(.headline)
                    DatePicker(
                        "End Date",
                        selection: $viewModel.endDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .accessibilityLabel("End Date")
                }
            }

            if !viewModel.isDateRangeValid {
                HStack {
                    Label("Start date must be before end date.", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                    Spacer()
                    Button("Swap") {
                        viewModel.swapDateRange()
                    }
                    .font(.footnote.weight(.semibold))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, width * 0.05)
    }
}
