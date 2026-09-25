//
//  CalendarDay.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import Foundation

/// How Crimson pins a logged day to a point in time.
///
/// A day is the unit of meaning in this app — a period started "on the 4th",
/// not "at 23:00" — so every stored date is midnight *UTC* on the day the
/// thing happened, and is only ever read back through `utc`, never through
/// whatever time zone the phone happens to be in.
///
/// Pinning both ends of the conversion is the whole point. Storing the local
/// midnight and reading it back locally looks correct right up until someone
/// travels: midnight on the 4th in London is 23:00 UTC on the 3rd, and reading
/// that same instant in Los Angeles puts the period a day early. Going through
/// UTC in both directions means the 4th stays the 4th wherever the phone is.
enum CalendarDay {
    /// The calendar stored dates are expressed in. Deliberately not the user's.
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /// The instant to persist for the calendar day `date` falls on, read in
    /// the user's own calendar. Use this on the way *in* to the database.
    static func stored(from date: Date, in local: Calendar = .current) -> Date {
        let day = local.dateComponents([.year, .month, .day], from: date)

        return utc.date(
            from: DateComponents(year: day.year, month: day.month, day: day.day)
        ) ?? date
    }

    /// The start of that same calendar day in the user's own calendar, for
    /// display and for the date maths the rest of the app does. Use this on
    /// the way *out* of the database.
    static func local(from stored: Date, in local: Calendar = .current) -> Date {
        let day = utc.dateComponents([.year, .month, .day], from: stored)

        return local.date(
            from: DateComponents(year: day.year, month: day.month, day: day.day)
        ) ?? stored
    }
}
