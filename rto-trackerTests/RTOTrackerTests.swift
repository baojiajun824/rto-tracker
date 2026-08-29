import XCTest
@testable import RTO_Tracker

final class RTOTrackerTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2
        return calendar
    }

    func testDayCountsCategorizeWeekdaysAndSkipWeekend() throws {
        let monday = try date(2025, 1, 6)
        let friday = try date(2025, 1, 10)
        let selections: [LocalDay: DayType] = [
            LocalDay(monday, calendar: calendar): .workFromOffice,
            LocalDay(try date(2025, 1, 7), calendar: calendar): .workFromHome,
            LocalDay(try date(2025, 1, 8), calendar: calendar): .leave
        ]

        let counts = RTOCalculator.dayCounts(
            selectedDays: selections,
            start: monday,
            end: friday,
            calendar: calendar
        )

        XCTAssertEqual(
            counts,
            DayCounts(
                workFromOfficeCount: 1,
                workFromHomeCount: 1,
                leaveCount: 1,
                unenteredCount: 2
            )
        )
    }

    func testIncludingPendingDaysKeepsDenominatorFixed() throws {
        let start = try date(2025, 1, 6)
        let end = try date(2025, 1, 10)
        let selections: [LocalDay: DayType] = [
            LocalDay(start, calendar: calendar): .workFromOffice,
            LocalDay(try date(2025, 1, 7), calendar: calendar): .workFromOffice,
            LocalDay(try date(2025, 1, 8), calendar: calendar): .workFromHome
        ]

        let summary = try XCTUnwrap(
            RTOCalculator.summary(
                selectedDays: selections,
                start: start,
                end: end,
                targetRTO: 60,
                includePendingDays: true,
                calendar: calendar
            )
        )

        XCTAssertEqual(try XCTUnwrap(summary.percentage), 40, accuracy: 0.001)
        XCTAssertEqual(summary.additionalOfficeDaysNeeded, 1)
        XCTAssertTrue(summary.canMeetGoalWithPendingDays)
    }

    func testExcludingPendingDaysAccountsForGrowingDenominator() throws {
        let start = try date(2025, 1, 6)
        let end = try date(2025, 1, 10)
        let selections: [LocalDay: DayType] = [
            LocalDay(start, calendar: calendar): .workFromOffice,
            LocalDay(try date(2025, 1, 7), calendar: calendar): .workFromHome
        ]

        let summary = try XCTUnwrap(
            RTOCalculator.summary(
                selectedDays: selections,
                start: start,
                end: end,
                targetRTO: 75,
                includePendingDays: false,
                calendar: calendar
            )
        )

        XCTAssertEqual(try XCTUnwrap(summary.percentage), 50, accuracy: 0.001)
        XCTAssertEqual(summary.additionalOfficeDaysNeeded, 2)
        XCTAssertTrue(summary.canMeetGoalWithPendingDays)
    }

    func testSummaryReportsWhenPendingDaysCannotMeetGoal() throws {
        let start = try date(2025, 1, 6)
        let end = try date(2025, 1, 10)
        let selections: [LocalDay: DayType] = [
            LocalDay(start, calendar: calendar): .workFromHome,
            LocalDay(try date(2025, 1, 7), calendar: calendar): .workFromHome,
            LocalDay(try date(2025, 1, 8), calendar: calendar): .workFromHome,
            LocalDay(try date(2025, 1, 9), calendar: calendar): .workFromHome
        ]

        let summary = try XCTUnwrap(
            RTOCalculator.summary(
                selectedDays: selections,
                start: start,
                end: end,
                targetRTO: 50,
                includePendingDays: true,
                calendar: calendar
            )
        )

        XCTAssertEqual(summary.additionalOfficeDaysNeeded, 3)
        XCTAssertFalse(summary.canMeetGoalWithPendingDays)
    }

    func testInvalidRangeHasNoSummary() throws {
        XCTAssertNil(
            RTOCalculator.summary(
                selectedDays: [:],
                start: try date(2025, 1, 10),
                end: try date(2025, 1, 6),
                targetRTO: 50,
                includePendingDays: true,
                calendar: calendar
            )
        )
    }

    func testLocalDayEncodingIsIndependentOfLaterTimeZoneChanges() throws {
        let original = LocalDay(try date(2025, 3, 10), calendar: calendar)
        let decoded = try JSONDecoder().decode(
            LocalDay.self,
            from: JSONEncoder().encode(original)
        )

        var pacificCalendar = calendar
        pacificCalendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        XCTAssertEqual(decoded, original)
        XCTAssertEqual(decoded.date(in: pacificCalendar).map { LocalDay($0, calendar: pacificCalendar) }, original)
    }

    @MainActor
    func testDirectSelectionPersistsAndCanClearADay() throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsSuiteName) }
        let day = try date(2025, 1, 6)
        let viewModel = CalendarViewModel(defaults: defaults, calendar: calendar)

        viewModel.setDayType(.workFromOffice, for: day)
        XCTAssertEqual(viewModel.dayType(for: day), .workFromOffice)

        let reloadedViewModel = CalendarViewModel(defaults: defaults, calendar: calendar)
        XCTAssertEqual(reloadedViewModel.dayType(for: day), .workFromOffice)

        reloadedViewModel.setDayType(.workFromHome, for: day)
        XCTAssertEqual(reloadedViewModel.dayType(for: day), .workFromHome)

        reloadedViewModel.setDayType(nil, for: day)
        XCTAssertNil(reloadedViewModel.dayType(for: day))
    }

    @MainActor
    func testLegacyPersistenceMigratesAndDuplicateDaysUseLastValue() throws {
        struct LegacyDay: Codable {
            let date: Date
            let type: String
        }

        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsSuiteName) }
        let day = try date(2025, 1, 6)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        defaults.set(
            try encoder.encode([
                LegacyDay(date: day, type: DayType.workFromHome.rawValue),
                LegacyDay(date: day, type: DayType.workFromOffice.rawValue)
            ]),
            forKey: CalendarViewModel.selectedDaysKey
        )

        let viewModel = CalendarViewModel(defaults: defaults, calendar: calendar)

        XCTAssertEqual(viewModel.dayType(for: day), .workFromOffice)
        let migratedData = try XCTUnwrap(defaults.data(forKey: CalendarViewModel.selectedDaysKey))
        let migratedObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: migratedData) as? [String: Any]
        )
        XCTAssertEqual(migratedObject["version"] as? Int, 1)
    }

    @MainActor
    func testCorruptPersistenceIsReportedAndLeftUntouched() throws {
        let defaults = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsSuiteName) }
        let corruptData = Data("not-json".utf8)
        defaults.set(corruptData, forKey: CalendarViewModel.selectedDaysKey)

        let viewModel = CalendarViewModel(defaults: defaults, calendar: calendar)

        XCTAssertNotNil(viewModel.persistenceErrorMessage)
        XCTAssertEqual(defaults.data(forKey: CalendarViewModel.selectedDaysKey), corruptData)
    }

    private var defaultsSuiteName: String {
        "RTOTrackerTests.\(name)"
    }

    private func makeDefaults() throws -> UserDefaults {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: defaultsSuiteName))
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        return defaults
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) throws -> Date {
        try XCTUnwrap(
            calendar.date(from: DateComponents(year: year, month: month, day: day))
        )
    }
}
