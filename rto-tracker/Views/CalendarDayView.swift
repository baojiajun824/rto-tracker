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
    let action: () -> Void
    let selectionAction: (DayType?) -> Void

    @ViewBuilder
    var body: some View {
        if isInteractable {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
            .contextMenu {
                ForEach(directSelectionTypes, id: \.self) { type in
                    Button {
                        selectionAction(type)
                    } label: {
                        Label(type.displayName, systemImage: type.systemImage)
                    }
                }
                Divider()
                Button(role: .destructive) {
                    selectionAction(nil)
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
            .accessibilityLabel(accessibilityDate)
            .accessibilityValue((dayType ?? .default).displayName)
            .accessibilityHint("Double tap to cycle. Long press to choose a day type.")
            .accessibilityAction(named: "Set Office") {
                selectionAction(.workFromOffice)
            }
            .accessibilityAction(named: "Set Home") {
                selectionAction(.workFromHome)
            }
            .accessibilityAction(named: "Set Leave") {
                selectionAction(.leave)
            }
            .accessibilityAction(named: "Clear") {
                selectionAction(nil)
            }
        } else {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(accessibilityDate), weekend")
        }
    }

    private var content: some View {
        VStack(spacing: 1) {
            Text(date.formatted(.dateTime.day()))
                .font(.callout.weight(.medium))
                .lineLimit(1)
            Image(systemName: statusType.systemImage)
                .font(.system(size: 9, weight: .semibold))
                .opacity(dayType == nil || !isInteractable ? 0 : 1)
        }
        .frame(width: 44, height: 44)
        .background(backgroundColor(for: dayType))
        .clipShape(Circle())
        .foregroundStyle(foregroundColor)
        .opacity(isInteractable ? 1 : 0.55)
    }

    private var statusType: DayType {
        dayType ?? .default
    }

    private var directSelectionTypes: [DayType] {
        [.workFromOffice, .workFromHome, .leave]
    }

    private var accessibilityDate: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    private var foregroundColor: Color {
        guard isInteractable else {
            return .secondary
        }
        return dayType == nil ? .primary : .white
    }

    private func backgroundColor(for dayType: DayType?) -> Color {
        guard isInteractable else {
            return .gray.opacity(0.2)
        }

        switch dayType {
        case .workFromOffice:
            return .green
        case .workFromHome:
            return .red.opacity(0.7)
        case .leave:
            return .gray
        case .default, .none:
            return .secondary.opacity(0.08)
        }
    }
}
