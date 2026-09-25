//
//  Log.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import Foundation
import SwiftData

/// What the user noted about one day.
///
/// One log per calendar day: `storedDate` is unique, so writing a second log
/// for a day it already has is a conflict rather than a duplicate. The date is
/// midnight UTC on that day — see `CalendarDay` — and is read back through
/// `date` in the user's own calendar.
@Model
final class DayLog {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute(.unique) var storedDate: Date = Date()

    var mood: Mood?
    var energy: Energy?
    /// Only meaningful on a day that falls inside a `Cycle` — nil otherwise.
    /// Nothing here enforces that; it's the caller's job not to record a flow
    /// on a day with no period.
    var flow: Flow?
    var symptoms: [Symptom] = []
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date,
        mood: Mood? = nil,
        energy: Energy? = nil,
        flow: Flow? = nil,
        symptoms: [Symptom] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.storedDate = CalendarDay.stored(from: date)
        self.mood = mood
        self.energy = energy
        self.flow = flow
        self.symptoms = symptoms
        self.notes = notes
    }
    
    var date: Date {
        get { CalendarDay.local(from: storedDate) }
        set { storedDate = CalendarDay.stored(from: newValue) }
    }

    var symptomSet: Set<Symptom> {
        get { Set(symptoms) }
        set { symptoms = Symptom.allCases.filter(newValue.contains) }
    }

    /// Nothing has been noted on this day. The store uses it to drop a log
    /// again once the user clears everything off it, rather than keeping an
    /// empty row per day they happened to open.
    var isEmpty: Bool {
        mood == nil &&
        energy == nil &&
        flow == nil &&
        symptoms.isEmpty &&
        displayNotes == nil
    }

    var displayNotes: String? {
        let trimmed = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty ?? true) ? nil : trimmed
    }
}

// MARK: - Scales

extension DayLog {
    /// The five-point mood scale, lowest first.
    enum Mood: String, Codable, CaseIterable, Identifiable, Sendable {
        case rough, low, okay, good, great

        var id: String { rawValue }
        var title: String { rawValue.ucFirst }

        var emoji: String {
            switch self {
            case .rough: "😞"
            case .low:   "😕"
            case .okay:  "😐"
            case .good:  "🙂"
            case .great: "😄"
            }
        }
    }

    /// The five-point energy scale, lowest first.
    enum Energy: String, Codable, CaseIterable, Identifiable, Sendable {
        case drained, tired, steady, lively, energetic

        var id: String { rawValue }
        var title: String { rawValue.ucFirst }

        var emoji: String {
            switch self {
            case .drained:   "😴"
            case .tired:     "🥱"
            case .steady:    "😐"
            case .lively:    "🙂"
            case .energetic: "⚡️"
            }
        }
    }

    /// How heavy the bleed was, lightest first.
    enum Flow: String, Codable, CaseIterable, Identifiable, Sendable {
        case spotting, light, medium, heavy

        var id: String { rawValue }
        var title: String { rawValue.ucFirst }
    }

    enum Symptom: String, Codable, CaseIterable, Identifiable, Sendable {
        case cramps,
             headache,
             bloating,
             tenderBreasts,
             fatigue,
             backPain,
             acne,
             nausea,
             cravings,
             insomnia

        var id: String { rawValue }

        var title: String {
            switch self {
            case .tenderBreasts: "Tender breasts"
            case .backPain:      "Back pain"
            default:             rawValue.ucFirst
            }
        }
    }
}
