//
//  InsightsScope.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

/// How far back the day-log charts look.
///
/// Bounded on purpose: an average taken over everything ever logged stops
/// moving after a year or two, which makes a change in how someone actually
/// feels invisible.
enum InsightsScope: String, CaseIterable, Identifiable {
    case threeMonths, sixMonths, twelveMonths

    var id: String { rawValue }

    var months: Int {
        switch self {
        case .threeMonths:  3
        case .sixMonths:    6
        case .twelveMonths: 12
        }
    }

    var title: String {
        switch self {
        case .threeMonths:  "3m"
        case .sixMonths:    "6m"
        case .twelveMonths: "12m"
        }
    }

    /// The phrase the cards use under their titles.
    var phrase: String {
        "last \(months) months"
    }

    /// The first day included, counting back from the start of this month so
    /// the window doesn't shift by a day each day.
    func start(from date: Date = Date(), calendar: Calendar = .current) -> Date {
        let thisMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        return calendar.date(byAdding: .month, value: -(months - 1), to: thisMonth) ?? thisMonth
    }
}

/// The colours the insight charts draw with.
///
/// Two, and only two, because every chart here shows a single measure — the
/// category names on the axis carry identity, so a colour per bar would imply
/// a grouping that isn't there. The pair is validated for colour-blind
/// separation and for contrast against the white card.
enum InsightsPalette {
    static let primary = Color(.red)
    static let secondary = Color(.green)
}
