import Foundation

struct DayCounts: Equatable {
    let workFromOfficeCount: Int
    let workFromHomeCount: Int
    let leaveCount: Int
    let unenteredCount: Int

    var enteredWorkdayCount: Int {
        workFromOfficeCount + workFromHomeCount
    }
}

struct RTOSummary: Equatable {
    let counts: DayCounts
    let percentage: Double?
    let additionalOfficeDaysNeeded: Int
    let canMeetGoalWithPendingDays: Bool

    func formattedPercentage(locale: Locale = .current) -> String? {
        percentage?.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(2))
        )
    }
}

enum RTOCalculator {
    static func summary(
        selectedDays: [LocalDay: DayType],
        start: Date,
        end: Date,
        targetRTO: Double,
        includePendingDays: Bool,
        calendar: Calendar = .current
    ) -> RTOSummary? {
        guard calendar.startOfDay(for: start) <= calendar.startOfDay(for: end) else {
            return nil
        }

        let counts = dayCounts(
            selectedDays: selectedDays,
            start: start,
            end: end,
            calendar: calendar
        )
        let denominator = counts.enteredWorkdayCount
            + (includePendingDays ? counts.unenteredCount : 0)
        let percentage = denominator > 0
            ? Double(counts.workFromOfficeCount) / Double(denominator) * 100
            : nil
        let target = min(max(targetRTO, 0), 100) / 100
        let recommendation = additionalOfficeDays(
            counts: counts,
            denominator: denominator,
            target: target,
            includePendingDays: includePendingDays,
            percentage: percentage
        )

        return RTOSummary(
            counts: counts,
            percentage: percentage,
            additionalOfficeDaysNeeded: recommendation.days,
            canMeetGoalWithPendingDays: recommendation.days <= counts.unenteredCount
                && recommendation.isMathematicallyReachable
        )
    }

    static func dayCounts(
        selectedDays: [LocalDay: DayType],
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> DayCounts {
        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar.startOfDay(for: end)
        guard normalizedStart <= normalizedEnd else {
            return DayCounts(
                workFromOfficeCount: 0,
                workFromHomeCount: 0,
                leaveCount: 0,
                unenteredCount: 0
            )
        }

        var currentDate = normalizedStart
        var office = 0
        var home = 0
        var leave = 0
        var pending = 0

        while currentDate <= normalizedEnd {
            if !calendar.isDateInWeekend(currentDate) {
                switch selectedDays[LocalDay(currentDate, calendar: calendar)] {
                case .workFromOffice:
                    office += 1
                case .workFromHome:
                    home += 1
                case .leave:
                    leave += 1
                case .default, .none:
                    pending += 1
                }
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return DayCounts(
            workFromOfficeCount: office,
            workFromHomeCount: home,
            leaveCount: leave,
            unenteredCount: pending
        )
    }

    private static func additionalOfficeDays(
        counts: DayCounts,
        denominator: Int,
        target: Double,
        includePendingDays: Bool,
        percentage: Double?
    ) -> (days: Int, isMathematicallyReachable: Bool) {
        if target == 0 || (percentage ?? -1) >= target * 100 {
            return (0, true)
        }

        if includePendingDays {
            guard denominator > 0 else {
                return (1, true)
            }
            let needed = Int(ceil(target * Double(denominator) - Double(counts.workFromOfficeCount)))
            return (max(needed, 0), true)
        }

        if denominator == 0 {
            return (1, true)
        }

        guard target < 1 else {
            return (counts.unenteredCount + 1, false)
        }

        let numerator = target * Double(denominator) - Double(counts.workFromOfficeCount)
        let needed = Int(ceil(numerator / (1 - target)))
        return (max(needed, 0), true)
    }
}
