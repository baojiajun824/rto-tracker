//
//  CalendarTitleView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct CalendarTitleView: View {
    var body: some View {
        Text("✨ RTO Tracker ✨")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .shadow(color: .gray, radius: 2, x: 1, y: 2)
    }
}
