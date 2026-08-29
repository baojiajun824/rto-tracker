# RTO Tracker

RTO Tracker is a small SwiftUI app for recording office, home, leave, and pending weekdays. It shows the office percentage for a selected date range and estimates how many pending days must become office days to reach a goal.

## Calculation

- Weekends and leave days are excluded.
- By default, RTO is `office / (office + home)`.
- When **Include Pending Days** is enabled, pending weekdays are also included in the denominator.
- If the selected goal cannot be reached with the pending days in the range, the app says so instead of showing an impossible recommendation.

## Data and privacy

All calendar entries and settings are stored locally on the device. The app has no accounts, analytics, network requests, or cloud synchronization. Clearing the app's calendar data from Settings is permanent.

Existing calendar entries from version 1.3 are migrated to the current date-only storage format the first time they are loaded.

## Requirements

- Xcode 16 or newer
- iOS 17 or newer
- iPhone or iPad

## Build and test

1. Open `rto-tracker.xcodeproj`.
2. Select the `rto-tracker` scheme and an iOS Simulator.
3. Run the app with **Product > Run**.
4. Run unit tests with **Product > Test**.
