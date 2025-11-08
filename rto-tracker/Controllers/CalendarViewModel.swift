//
//  CalendarViewModel.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import Foundation

class CalendarViewModel: ObservableObject {
    @Published var selectedDays: [Date: DayType] = [:] {
        didSet {
            saveSelectedDays()
        }
    }

    @Published var startDate: Date = Date() {
        didSet {
            saveDate(forKey: "startDate", date: startDate)
        }
    }

    @Published var endDate: Date = Date() {
        didSet {
            saveDate(forKey: "endDate", date: endDate)
        }
    }

    private let calendar = Calendar.current
    private let userDefaultsKey = "selectedDays"

    init() {
        loadSelectedDays()
        startDate = loadDate(forKey: "startDate") ?? Date()
        endDate = loadDate(forKey: "endDate") ?? Date()
    }

    // Save selectedDays to UserDefaults
    private func saveSelectedDays() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let dataToSave = selectedDays.map { EncodableDay(date: $0.key, type: $0.value.rawValue) }
        if let encoded = try? encoder.encode(dataToSave) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    // Load selectedDays from UserDefaults
    private func loadSelectedDays() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([EncodableDay].self, from: savedData) {
                selectedDays = Dictionary(uniqueKeysWithValues: decoded.map { ($0.date, DayType(rawValue: $0.type) ?? .default) })
            }
        }
    }

    // Save individual dates to UserDefaults
    private func saveDate(forKey key: String, date: Date) {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        UserDefaults.standard.set(dateString, forKey: key)
    }

    // Load individual dates from UserDefaults
    private func loadDate(forKey key: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        if let dateString = UserDefaults.standard.string(forKey: key) {
            return formatter.date(from: dateString)
        }
        return nil
    }

    // Toggle day type or reset to default
    func toggleDayType(for date: Date) {
        if let currentType = selectedDays[date] {
            selectedDays[date] = currentType.next()
            if selectedDays[date] == .default {
                selectedDays.removeValue(forKey: date)
            }
        } else {
            selectedDays[date] = .workFromOffice
        }
    }

    // Calculate the RTO percentage for a given period
    func calculateRTOPercentage(start: Date, end: Date, includeUnentered: Bool) -> String {
        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar.startOfDay(for: end)

        // Generate all days in the range
        var totalDays = 0
        var workFromOfficeCount = 0
        var workFromHomeCount = 0
        var unenteredDaysCount = 0

        var currentDate = normalizedStart
        while currentDate <= normalizedEnd {
            if !calendar.isDateInWeekend(currentDate) {
                totalDays += 1
                if let dayType = selectedDays[currentDate] {
                    switch dayType {
                    case .workFromOffice:
                        workFromOfficeCount += 1
                    case .workFromHome:
                        workFromHomeCount += 1
                    default:
                        break
                    }
                } else {
                    // Count unentered days
                    unenteredDaysCount += 1
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        // Determine the denominator based on the setting
        let denominator = includeUnentered
            ? (workFromOfficeCount + workFromHomeCount + unenteredDaysCount) // Include unentered days
            : (workFromOfficeCount + workFromHomeCount) // Exclude unentered days

        // Avoid division by zero
        guard denominator > 0 else { return "0.00" }

        let rtoPercentage = (Double(workFromOfficeCount) / Double(denominator)) * 100
        return String(format: "%.2f", rtoPercentage)
    }

    // Calculate day counts for different day types within the selected period
    func calculateDayCounts(start: Date, end: Date) -> DayCounts {
        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar.startOfDay(for: end)

        // Generate all dates within the period
        var currentDate = normalizedStart
        var workFromOfficeCount = 0
        var workFromHomeCount = 0
        var leaveCount = 0
        var totalDaysInRange = 0

        while currentDate <= normalizedEnd {
            // Skip weekends
            if !calendar.isDateInWeekend(currentDate) {
                totalDaysInRange += 1

                if let dayType = selectedDays[currentDate] {
                    switch dayType {
                    case .workFromOffice:
                        workFromOfficeCount += 1
                    case .workFromHome:
                        workFromHomeCount += 1
                    case .leave:
                        leaveCount += 1
                    default:
                        break
                    }
                }
            }
            // Move to the next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        let unenteredCount = totalDaysInRange - (workFromOfficeCount + workFromHomeCount + leaveCount)

        return DayCounts(
            workFromOfficeCount: workFromOfficeCount,
            workFromHomeCount: workFromHomeCount,
            leaveCount: leaveCount,
            unenteredCount: unenteredCount
        )
    }
    
    func calculateAdditionalDaysNeeded(start: Date, end: Date, targetRTO: Double, includeUnentered: Bool) -> Int {
        let counts = calculateDayCounts(start: start, end: end)

        let currentWorkFromOffice = counts.workFromOfficeCount
        let denominator = includeUnentered
            ? (counts.workFromOfficeCount + counts.workFromHomeCount + counts.unenteredCount)
            : (counts.workFromOfficeCount + counts.workFromHomeCount)

        guard denominator > 0 else { return Int(ceil(targetRTO / 100.0)) }

        let targetNumerator = (targetRTO / 100.0) * Double(denominator)
        let additionalNeeded = max(0, Int(ceil(targetNumerator - Double(currentWorkFromOffice))))
        return additionalNeeded
    }
}

// Struct for encapsulating day counts
struct DayCounts {
    let workFromOfficeCount: Int
    let workFromHomeCount: Int
    let leaveCount: Int
    let unenteredCount: Int
}

// Helper struct for persistence
struct EncodableDay: Codable {
    let date: Date
    let type: String
}
