//
//  Dates.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

//Cycle(startDate: toDate("2026-05-11"), endDate: toDate("2026-05-15")),
//Cycle(startDate: toDate("2026-06-10"), endDate: toDate("2026-06-13")),
//Cycle(startDate: toDate("2026-07-09"), endDate: toDate("2026-07-12")),
//Cycle(startDate: toDate("2026-08-05"), endDate: toDate("2026-08-08")),
//Cycle(startDate: toDate("2026-09-04"), endDate: toDate("2026-09-07"))

import Foundation

let weekShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

func toDate(_ dateString: String) -> Date {
    let date = try? Date(
        dateString, strategy: Date.ISO8601FormatStyle().year().month().day()
    )
    
    return date ?? Date()
}

func daysIn(in month: Date) -> [Date?] {
    let calendar = Calendar.current
    
    guard
        let monthInterval = calendar.dateInterval(of: .month, for: month),
        let dayCount = calendar.range(of: .day, in: .month, for: month)?.count
    else {
        return []
    }

    let firstDay = monthInterval.start
    let weekday = calendar.component(.weekday, from: firstDay)
    let leadingEmpty = (weekday + 5) % 7
    let dates = (0..<dayCount).compactMap {
        calendar.date(byAdding: .day, value: $0, to: firstDay)
    }

    return Array(repeating: nil, count: leadingEmpty) + dates
}

/// Get a start, end in an order in which they're chronological. so if end is for some reason
/// earlier than start, then it would be flipped where end becomes start instead...
func ordered(_ start: Date, _ end: Date?) -> (start: Date, end: Date?) {
    guard let end, end < start else {
        return (start, end)
    }
    
    return (end, start)
}

enum DateFormat {
    static let calendarDay = Date.ISO8601FormatStyle(timeZone: .current)
          .year().month().day()
 }
