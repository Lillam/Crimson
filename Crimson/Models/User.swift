//
//  User.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import Foundation
import SwiftData

/// The little the app knows about the person using it. Purely for
/// personalisation — none of it feeds the cycle maths.
///
/// There is only ever one of these. Nothing in SwiftData enforces that, so
/// reads should fetch with a limit of one and writes should update the
/// existing row rather than inserting a second.
@Model
final class User {
    var name: String = ""

    /// Day and month only — stored as two numbers rather than a date, because
    /// there is no year to anchor one to. Read and written through `birthday`.
    var birthdayDay: Int?
    var birthdayMonth: Int?

    init(name: String = "", birthday: Birthday? = nil) {
        self.name = name
        self.birthdayDay = birthday?.day
        self.birthdayMonth = birthday?.month
    }

    /// The birthday as one value, or nil if they didn't give one. Setting it
    /// to nil clears both halves, so the two can never disagree.
    var birthday: Birthday? {
        get {
            guard let birthdayDay, let birthdayMonth else {
                return nil
            }

            return Birthday(day: birthdayDay, month: birthdayMonth)
        }
        
        set {
            birthdayDay = newValue?.day
            birthdayMonth = newValue?.month
        }
    }

    /// The name with surrounding whitespace removed, or nil if they didn't
    /// give one. What the UI should address them by.
    var displayName: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Whether `date` falls on their birthday.
    func isBirthday(_ date: Date, in calendar: Calendar = .current) -> Bool {
        birthday?.matches(date, in: calendar) ?? false
    }
}

extension User {
    /// The only data in which we care about for the application is the month
    /// and day, year not necessary, doesn't need to know anything more this
    /// is just for the application to do fancy things when it comes to the user's
    /// birthday.
    struct Birthday: Equatable, Hashable, Codable, Sendable {
        var day: Int
        var month: Int

        func matches(_ date: Date, in calendar: Calendar = .current) -> Bool {
            let components = calendar.dateComponents([.day, .month], from: date)
            return components.day == day && components.month == month
        }

        var formatted: String {
            let monthName = Calendar.current.monthSymbols[max(0, min(month - 1, 11))]
            return "\(day) \(monthName)"
        }
    }
}
