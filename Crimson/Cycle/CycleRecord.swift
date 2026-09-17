//
//  Cycle.swift
//  Crimson
//
//  Created by Liam Taylor on 08/06/2026.
//

import Foundation

struct CycleRecord: Identifiable, Hashable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    
    init(id: UUID = UUID(), startDate: Date, endDate: Date? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
    }
    
    /// Whether the period has been started but not yet ended.
    var isOngoing: Bool {
        endDate == nil
    }
    
    /// The last day this record covers. An ongoing period runs up to today.
    var effectiveEndDate: Date {
        endDate ?? max(Date(), startDate)
    }
    
    /// Whether `date` falls on one of this record's days.
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return day >= calendar.startOfDay(for: startDate) && day <= calendar.startOfDay(for: effectiveEndDate)
    }
    
    var bleedLength: Int? {
        guard let endDate else {
            return nil
        }
        
        // map over the days and get the total number of days that the cycle
        // had lasted for. Inclusive of both ends, so 11th → 15th is 5 days.
        let calendar = Calendar.current
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: endDate)
        ).day.map {
            $0 + 1
        }
    }
}
