//
//  SwiftUIView.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

//
//  SwiftUIView.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let dayType: DayType?
    let isInteractable: Bool

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        Text(formatter.string(from: date))
            .font(.body)
            .frame(width: 30, height: 30)
            .lineLimit(1)
            .padding(5)
            .background(isInteractable ? backgroundColor(for: dayType) : Color.gray.opacity(0.3))
            .clipShape(Circle())
            .foregroundColor(isInteractable ? (dayType == nil ? .primary : .white) : .gray)
            .opacity(isInteractable ? 1.0 : 0.5) // Reduce opacity for non-interactable days
    }

    private func backgroundColor(for dayType: DayType?) -> Color {
        switch dayType {
        case .workFromOffice:
            return .green
        case .workFromHome:
            return .red.opacity(0.7)
        case .leave:
            return .gray
        case .default, .none:
            return .clear
        }
    }
}
