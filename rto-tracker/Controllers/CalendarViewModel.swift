//
//  CalendarViewModel.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import Foundation
import OSLog

@MainActor
final class CalendarViewModel: ObservableObject {
    static let selectedDaysKey = "selectedDays"

    @Published private(set) var selectedDays: [LocalDay: DayType] = [:]
    @Published private(set) var persistenceErrorMessage: String?
    @Published var startDate: Date = Date() {
        didSet {
            defaults.set(startDate, forKey: Keys.startDate)
        }
    }
    @Published var endDate: Date = Date() {
        didSet {
            defaults.set(endDate, forKey: Keys.endDate)
        }
    }

    private enum Keys {
        static let startDate = "startDate"
        static let endDate = "endDate"
    }

    private struct PersistencePayload: Codable {
        let version: Int
        let days: [StoredDay]
    }

    private struct StoredDay: Codable {
        let day: LocalDay
        let type: String
    }

    private struct LegacyStoredDay: Codable {
        let date: Date
        let type: String
    }

    private enum PersistenceError: LocalizedError {
        case unsupportedVersion(Int)

        var errorDescription: String? {
            switch self {
            case .unsupportedVersion(let version):
                return "Calendar data uses unsupported format version \(version)."
            }
        }
    }

    private let calendar: Calendar
    private let defaults: UserDefaults
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "RTOTracker",
        category: "CalendarPersistence"
    )

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar

        let today = Date()
        let defaultStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: today)
        ) ?? today
        startDate = Self.loadDate(forKey: Keys.startDate, defaults: defaults) ?? defaultStart
        endDate = Self.loadDate(forKey: Keys.endDate, defaults: defaults) ?? today
        loadSelectedDays()
    }

    var isDateRangeValid: Bool {
        calendar.startOfDay(for: startDate) <= calendar.startOfDay(for: endDate)
    }

    func dayType(for date: Date) -> DayType? {
        selectedDays[LocalDay(date, calendar: calendar)]
    }

    func toggleDayType(for date: Date) {
        let day = LocalDay(date, calendar: calendar)
        let nextType = selectedDays[day]?.next() ?? .workFromOffice
        setDayType(nextType == .default ? nil : nextType, for: date)
    }

    func setDayType(_ type: DayType?, for date: Date) {
        let day = LocalDay(date, calendar: calendar)
        let storedType = type == .default ? nil : type
        guard selectedDays[day] != storedType else {
            return
        }

        if let storedType {
            selectedDays[day] = storedType
        } else {
            selectedDays.removeValue(forKey: day)
        }
        saveSelectedDays()
    }

    func summary(
        targetRTO: Double,
        includePendingDays: Bool,
        includeWeekendOffice: Bool = false
    ) -> RTOSummary? {
        RTOCalculator.summary(
            selectedDays: selectedDays,
            start: startDate,
            end: endDate,
            targetRTO: targetRTO,
            includePendingDays: includePendingDays,
            includeWeekendOffice: includeWeekendOffice,
            calendar: calendar
        )
    }

    func swapDateRange() {
        let previousStart = startDate
        startDate = endDate
        endDate = previousStart
    }

    func clearCalendarData() {
        selectedDays.removeAll()
        defaults.removeObject(forKey: Self.selectedDaysKey)
        persistenceErrorMessage = nil
    }

    func dismissPersistenceError() {
        persistenceErrorMessage = nil
    }

    private func saveSelectedDays() {
        let storedDays = selectedDays
            .map { StoredDay(day: $0.key, type: $0.value.rawValue) }
            .sorted { $0.day < $1.day }
        let payload = PersistencePayload(version: 1, days: storedDays)

        do {
            defaults.set(try JSONEncoder().encode(payload), forKey: Self.selectedDaysKey)
        } catch {
            reportPersistenceError("Your latest calendar change could not be saved.", error: error)
        }
    }

    private func loadSelectedDays() {
        guard let savedData = defaults.data(forKey: Self.selectedDaysKey) else {
            return
        }

        do {
            if let payload = try? JSONDecoder().decode(PersistencePayload.self, from: savedData) {
                guard payload.version == 1 else {
                    throw PersistenceError.unsupportedVersion(payload.version)
                }
                selectedDays = makeDayDictionary(from: payload.days)
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let legacyDays = try decoder.decode([LegacyStoredDay].self, from: savedData)
            selectedDays = legacyDays.reduce(into: [:]) { result, storedDay in
                guard let type = DayType(rawValue: storedDay.type), type != .default else {
                    return
                }
                result[LocalDay(storedDay.date, calendar: calendar)] = type
            }
            saveSelectedDays()
        } catch {
            reportPersistenceError(
                "Saved calendar data could not be read. It has been left untouched.",
                error: error
            )
        }
    }

    private func makeDayDictionary(from storedDays: [StoredDay]) -> [LocalDay: DayType] {
        storedDays.reduce(into: [:]) { result, storedDay in
            guard let type = DayType(rawValue: storedDay.type), type != .default else {
                return
            }
            result[storedDay.day] = type
        }
    }

    private func reportPersistenceError(_ message: String, error: Error) {
        persistenceErrorMessage = message
        logger.error("\(message, privacy: .public) \(error.localizedDescription, privacy: .public)")
    }

    private static func loadDate(forKey key: String, defaults: UserDefaults) -> Date? {
        if let date = defaults.object(forKey: key) as? Date {
            return date
        }

        let formatter = ISO8601DateFormatter()
        if let dateString = defaults.string(forKey: key) {
            return formatter.date(from: dateString)
        }
        return nil
    }
}
