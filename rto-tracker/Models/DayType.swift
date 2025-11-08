//
//  DayType.swift
//  RTO Tracker
//
//  Created by Jiajun Bao on 2024-11-15.
//

import Foundation

enum DayType: String, Codable, CaseIterable {
    case workFromOffice = "Work from Office"
    case workFromHome = "Work from Home"
    case leave = "Leave"
    case `default` = "Default"

    func next() -> DayType {
        switch self {
        case .workFromOffice:
            return .workFromHome
        case .workFromHome:
            return .leave
        case .leave:
            return .default
        case .default:
            return .workFromOffice
        }
    }
}
