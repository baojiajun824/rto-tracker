//
//  LegendView.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import SwiftUI

struct LegendView: View {
    var body: some View {
        HStack(spacing: 20) {
            LegendItem(color: .green, label: "Work from Office")
            LegendItem(color: .red.opacity(0.7), label: "Work from Home")
            LegendItem(color: .gray, label: "Leave/Holiday")
        }
        .font(.caption2) // Downsize the font for the entire legend
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2) // Smaller font for individual labels
        }
    }
}
