import Foundation

struct LocalDay: Codable, Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    init(_ date: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        year = components.year ?? 1970
        month = components.month ?? 1
        day = components.day ?? 1
    }

    func date(in calendar: Calendar = .current) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    static func < (lhs: LocalDay, rhs: LocalDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
