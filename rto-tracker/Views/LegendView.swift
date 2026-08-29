//
//  LegendView.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

struct LegendView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 8) {
            LegendItem(type: .workFromOffice, color: .green)
            LegendItem(type: .workFromHome, color: .red)
            LegendItem(type: .leave, color: .gray)
            LegendItem(type: .default, color: .blue)
        }
        .font(.caption)
        .padding(.horizontal)
    }
}

struct LegendItem: View {
    let type: DayType
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: type.systemImage)
                .foregroundStyle(color)
                .frame(width: 14)
            Text(type.displayName)
        }
        .accessibilityElement(children: .combine)
    }
}
