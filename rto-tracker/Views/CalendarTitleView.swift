//
//  CalendarTitleView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct CalendarTitleView: View {
    var body: some View {
        Label("RTO Tracker", systemImage: "calendar")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(.blue)
    }
}
