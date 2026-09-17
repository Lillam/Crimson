//
//  Dates.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

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

enum DateFormat {
    static let calendarDay = Date.ISO8601FormatStyle(timeZone: .current)
          .year().month().day()
 }
