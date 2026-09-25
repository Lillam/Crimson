//
//  Cycle.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import Foundation
import SwiftData

/// One logged period: the day it started, and the day it finished if it has.
///
/// Both dates are held as midnight UTC on the day in question — see
/// `CalendarDay` — and read back through `start`/`end`, which hand out dates
/// in the user's own calendar. Nothing outside this type should touch the
/// `stored…` properties.
@Model
final class Cycle {
    /// Our own identifier rather than SwiftData's `persistentModelID`, so a
    /// cycle keeps its identity across an edit that rewrites it, and so chart
    /// samples and `ForEach` have something stable to key on.
    @Attribute(.unique) var id: UUID = UUID()

    var storedStart: Date = Date()
    var storedEnd: Date?

    init(id: UUID = UUID(), start: Date, end: Date? = nil) {
        self.id = id
        self.storedStart = CalendarDay.stored(from: start)
        self.storedEnd = end.map { CalendarDay.stored(from: $0) }
    }

    /// The first day of the period, in the user's calendar.
    var start: Date {
        get { CalendarDay.local(from: storedStart) }
        set { storedStart = CalendarDay.stored(from: newValue) }
    }

    /// The last day of the period, or nil while it is still going.
    var end: Date? {
        get { storedEnd.map { CalendarDay.local(from: $0) } }
        set { storedEnd = newValue.map { CalendarDay.stored(from: $0) } }
    }

    /// Whether the period has been started but not yet ended.
    var isOngoing: Bool {
        storedEnd == nil
    }

    /// The last day this cycle covers. An ongoing period runs up to today.
    var effectiveEnd: Date {
        end ?? max(Date(), start)
    }
    
    func overlaps(_ start: Date, through end: Date, in calendar: Calendar = .current) -> Bool {
        self.start <= end && calendar.startOfDay(for: effectiveEnd) >= start
    }

    /// Whether `date` falls on one of this cycle's days.
    func contains(_ date: Date, in calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)

        return day >= calendar.startOfDay(for: start) &&
               day <= calendar.startOfDay(for: effectiveEnd)
    }

    /// How many days the bleed lasted, inclusive of both ends. Nil while the
    /// period is still ongoing, since it doesn't have a length yet.
    var length: Int? {
        guard let end else {
            return nil
        }

        let calendar = Calendar.current

        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: start),
            to: calendar.startOfDay(for: end)
        ).day.map { $0 + 1 }
    }
}
