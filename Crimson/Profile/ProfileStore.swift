//
//  ProfileStore.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import Foundation

/// A day and month with no year — enough to say happy birthday, and nothing
/// more personal than that.
struct Birthday: Equatable, Codable {
    var day: Int
    var month: Int
    
    /// Whether `date` falls on this birthday.
    func matches(_ date: Date, calendar: Calendar = .current) -> Bool {
        let components = calendar.dateComponents([.day, .month], from: date)
        return components.day == day && components.month == month
    }
    
    /// "14 March"
    var formatted: String {
        let calendar = Calendar.current
        let monthName = calendar.monthSymbols[max(0, min(month - 1, 11))]
        return "\(day) \(monthName)"
    }
}

/// The little the app knows about the person using it, persisted in
/// `UserDefaults`. Purely for personalisation — none of it affects the cycle
/// maths.
@Observable
final class ProfileStore {
    private let defaults: UserDefaults
    
    private enum Key {
        static let name = "profile.name"
        static let birthday = "profile.birthday"
        static let hasSeenWelcome = "profile.hasSeenWelcome"
    }
    
    /// Whatever the user wants to be called. Free text, no validation.
    var name: String {
        didSet { defaults.set(name, forKey: Key.name) }
    }
    
    var birthday: Birthday? {
        didSet {
            if let data = try? JSONEncoder().encode(birthday) {
                defaults.set(data, forKey: Key.birthday)
            } else {
                defaults.removeObject(forKey: Key.birthday)
            }
        }
    }
    
    /// Persisted: whether the user has been through (or skipped) the welcome.
    /// Checked once at launch to decide whether to present it.
    var hasSeenWelcome: Bool {
        didSet { defaults.set(hasSeenWelcome, forKey: Key.hasSeenWelcome) }
    }
    
    /// Not persisted: whether the welcome is on screen right now. Kept apart
    /// from `hasSeenWelcome` so "show it next launch" (delete profile) and
    /// "show it now" (edit profile) can both exist.
    var isWelcomePresented = false
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        name = defaults.string(forKey: Key.name) ?? ""
        birthday = defaults.data(forKey: Key.birthday).flatMap { try? JSONDecoder().decode(Birthday.self, from: $0) }
        hasSeenWelcome = defaults.bool(forKey: Key.hasSeenWelcome)
    }
    
    /// The name with surrounding whitespace removed, or nil if they didn't give one.
    var displayName: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    func isBirthday(_ date: Date) -> Bool {
        birthday?.matches(date) ?? false
    }
    
    /// Called once when the app view first appears.
    func presentWelcomeIfNeeded() {
        isWelcomePresented = !hasSeenWelcome
    }
    
    /// Brings the welcome flow up straight away, prefilled with the current
    /// profile — this is how the profile gets edited.
    func showWelcomeAgain() {
        isWelcomePresented = true
    }
    
    /// Finishing or skipping the welcome.
    func completeWelcome() {
        hasSeenWelcome = true
        isWelcomePresented = false
    }
    
    /// Forgets everything and arranges for the welcome to run again the next
    /// time the app is opened. Deliberately doesn't present it now.
    func deleteProfile() {
        name = ""
        birthday = nil
        hasSeenWelcome = false
    }
}
