//
//  Cycle.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import Foundation

/// helpers for the internal class which will be for building what the store needs.
/// here we're just going to be looking at getting the cycle duration — bleed
/// length lives on `Cycle` itself.

/// Whole calendar days between two consecutive period starts. Uses the
/// calendar rather than dividing seconds so daylight-saving changes can't
/// shave a day off a cycle.
func getCycleLengthFromRecords(from end: Cycle, to start: Cycle?) -> Int? {
    let calendar = Calendar.current
    
    guard let starting = start else {
        return nil
    }
    
    return calendar.dateComponents(
        [.day],
        from: calendar.startOfDay(for: starting.start),
        to: calendar.startOfDay(for: end.start)
    ).day
}
