//
//  Route.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import Foundation

enum Route: Hashable, Identifiable, CaseIterable {
    case calendar
    case day(String)
    case insights
    case settings
    
    var id: String {
        switch self {
        case .day(let date): return "day.\(date)"
        default: return "\(self)"
        }
    }
    
    var icon: String {
        switch self {
        case .calendar: "calendar"
        case .day: "sun.max"
        case .insights: "chart.bar"
        case .settings: "gearshape"
        }
    }
    
    static var allCases: [Route] {
        [.calendar, .day("today"), .insights, .settings]
    }

    /// The canonical route for this tab, ignoring any associated value.
    /// Every `.day(_)` collapses to the same value so that a specific date
    /// (e.g. `.day("2026-06-26")`) is treated as the Day tab.
    var base: Route {
        switch self {
        case .day: return .day("today")
        default: return self
        }
    }
}
