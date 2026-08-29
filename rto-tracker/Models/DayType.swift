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

    var displayName: String {
        switch self {
        case .workFromOffice:
            return "Office"
        case .workFromHome:
            return "Home"
        case .leave:
            return "Leave"
        case .default:
            return "Pending"
        }
    }

    var systemImage: String {
        switch self {
        case .workFromOffice:
            return "building.2.fill"
        case .workFromHome:
            return "house.fill"
        case .leave:
            return "airplane"
        case .default:
            return "circle.dotted"
        }
    }
}
