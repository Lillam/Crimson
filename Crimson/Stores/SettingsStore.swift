//
//  SettingsStore.swift
//  Crimson
//
//  Created by Liam Taylor on 20/09/2026.
//

import Foundation

/// How far the calendar reaches either side of the current month. Bounding it
/// keeps the month list — and the projection that's drawn over it — to a size
/// worth rendering; the user can lift the bound if they'd rather scroll on
/// forever.
enum CalendarRange: Equatable {
    /// No limit: the calendar keeps loading months as the user scrolls.
    case unbounded
    /// A window of `years` back and `years` forward from this month.
    case years(Int)

    /// What the settings stepper allows. A year is the smallest window that
    /// still shows a full cycle history; past a decade the difference stops
    /// being meaningful.
    static let yearBounds = 1...10
    static let standard: CalendarRange = .years(2)

    /// How it's persisted: `0` is unbounded, anything else is a year count.
    /// Clamped on the way in so a hand-edited default can't produce a window
    /// the settings page couldn't have made.
    init(stored: Int) {
        guard stored > 0 else {
            self = .unbounded
            return
        }

        self = .years(min(stored, CalendarRange.yearBounds.upperBound))
    }

    var stored: Int {
        switch self {
        case .unbounded:        return 0
        case .years(let years): return years
        }
    }

    /// Months either side of the current one, or nil when unbounded.
    var months: Int? {
        switch self {
        case .unbounded:        return nil
        case .years(let years): return years * 12
        }
    }

    var isUnbounded: Bool {
        self == .unbounded
    }

    /// "No limit" / "2 years either way"
    var summary: String {
        switch self {
        case .unbounded:        return "No limit"
        case .years(let years): return "\(years) \(years == 1 ? "year" : "years") either way"
        }
    }
}

/// App preferences — how Crimson behaves rather than who's using it (that's
/// `ProfileStore`). Persisted in `UserDefaults`, same as the profile.
@Observable final class SettingsStore {
    private let defaults: UserDefaults

    private enum Key {
        static let calendarRange = "settings.calendarRange"
        static let theme = "settings.theme"
    }

    var calendarRange: CalendarRange {
        didSet { defaults.set(calendarRange.stored, forKey: Key.calendarRange) }
    }

    /// Light, dark, or whatever the device is set to.
    var theme: AppTheme {
        didSet { defaults.set(theme.rawValue, forKey: Key.theme) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // A missing key reads as 0, which is a legitimate stored value
        // (unbounded), so the absence has to be checked rather than the value.
        calendarRange = defaults.object(forKey: Key.calendarRange) == nil
            ? .standard
            : CalendarRange(stored: defaults.integer(forKey: Key.calendarRange))

        // An unrecognised or missing value follows the device, which is the
        // safe default — it can never leave the app in an appearance the user
        // didn't pick.
        theme = defaults.string(forKey: Key.theme)
            .flatMap(AppTheme.init(rawValue:)) ?? .system
    }

    /// Switches between a bounded and an unbounded calendar, remembering
    /// nothing about the old window — coming back off "no limit" starts from
    /// the standard one.
    func setCalendarUnbounded(_ unbounded: Bool) {
        calendarRange = unbounded ? .unbounded : .standard
    }

    /// Nudges the window's size, within `CalendarRange.yearBounds`. A no-op
    /// while the calendar is unbounded.
    func adjustCalendarYears(by delta: Int) {
        guard case .years(let years) = calendarRange else {
            return
        }

        let bounds = CalendarRange.yearBounds
        calendarRange = .years(min(max(years + delta, bounds.lowerBound), bounds.upperBound))
    }
}
