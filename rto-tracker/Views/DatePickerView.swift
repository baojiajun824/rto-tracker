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
        HStack(spacing: width * 0.1) {
            VStack {
                Text("Start Date")
                    .font(.headline)
                DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                    .labelsHidden()
            }
            VStack {
                Text("End Date")
                    .font(.headline)
                DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                    .labelsHidden()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, width * 0.05)
    }
}
