//
//  SettingsButtonView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct SettingsButtonView: View {
    @Binding var showSettings: Bool
    @ObservedObject var calendarViewModel: CalendarViewModel

    var body: some View {
        Button {
            showSettings = true
        } label: {
            Label("Settings", systemImage: "gearshape")
                .frame(minHeight: 44)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(calendarViewModel: calendarViewModel)
        }
    }
}
