//
//  SettingsButtonView.swift
//  rto-tracker
//
//  Created by Jiajun Bao on 2024-11-20.
//

import SwiftUI

struct SettingsButtonView: View {
    @Binding var showSettings: Bool // Binding to control the sheet presentation

    var body: some View {
        Button(action: {
            showSettings = true
        }) {
            Image(systemName: "gearshape") // Use gear icon for settings
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24) // Set icon size
                .foregroundColor(.blue) // Icon color
                .padding(8) // Add padding for better tappable area
                .background(Circle().fill(Color.blue.opacity(0.1))) // Circle background
        }
        .sheet(isPresented: $showSettings) {
            SettingsView() // Present the settings screen
        }
    }
}
