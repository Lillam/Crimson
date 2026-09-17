//
//  DayEntry.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import Foundation

/// What the user noted about one day. Everything is optional — an entry
/// only exists once something's been logged, and disappears again if it's
/// all cleared.
struct DayEntry: Codable, Equatable {
    /// 1 (poor) … 5 (great).
    var mood: Int?
    /// 1 (drained) … 5 (energised).
    var energy: Int?
    var flow: Flow?
    var symptoms: Set<Symptom> = []
    var notes: String = ""
    
    var isEmpty: Bool {
        mood == nil && energy == nil && flow == nil && symptoms.isEmpty
            && notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    enum Flow: String, Codable, CaseIterable, Identifiable {
        case spotting, light, medium, heavy
        
        var id: String { rawValue }
        var title: String { rawValue.ucFirst }
    }
    
    enum Symptom: String, Codable, CaseIterable, Identifiable {
        case cramps, headache, bloating, tenderBreasts, fatigue, backPain, acne, nausea, cravings, insomnia
        
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

/// The five-point scales, with an emoji and a word for each step.
enum Scale {
    static let mood: [(emoji: String, label: String)] = [
        ("😞", "Rough"), ("😕", "Low"), ("😐", "Okay"), ("🙂", "Good"), ("😄", "Great"),
    ]
    static let energy: [(emoji: String, label: String)] = [
        ("😴", "Drained"), ("🥱", "Tired"), ("😐", "Steady"), ("🙂", "Lively"), ("⚡️", "Energised"),
    ]
}

/// Day entries keyed by calendar day, persisted as a small JSON file in the
/// app's documents folder.
@Observable
final class DayEntryStore {
    private(set) var entries: [String: DayEntry] = [:]
    private let fileURL: URL?
    
    init(fileURL: URL? = DayEntryStore.defaultFileURL) {
        self.fileURL = fileURL
        load()
    }
    
    private static var defaultFileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("day-entries.json")
    }
    
    /// Days are keyed as "yyyy-MM-dd" in the local calendar, so an entry
    /// stays on the day it was written regardless of time zone changes.
    private func key(for date: Date) -> String {
        date.formatted(DateFormat.calendarDay)
    }
    
    func entry(for date: Date) -> DayEntry {
        entries[key(for: date)] ?? DayEntry()
    }
    
    func hasEntry(on date: Date) -> Bool {
        entries[key(for: date)] != nil
    }
    
    /// Applies a change to the day's entry, dropping the entry entirely if
    /// nothing's left in it.
    func update(for date: Date, _ change: (inout DayEntry) -> Void) {
        var entry = entry(for: date)
        change(&entry)
        
        let key = key(for: date)
        if entry.isEmpty {
            entries.removeValue(forKey: key)
        } else {
            entries[key] = entry
        }
        
        save()
    }
    
    private func load() {
        guard
            let fileURL,
            let data = try? Data(contentsOf: fileURL),
            let decoded = try? JSONDecoder().decode([String: DayEntry].self, from: data)
        else { return }
        
        entries = decoded
    }
    
    private func save() {
        guard let fileURL, let data = try? JSONEncoder().encode(entries) else {
            return
        }
        
        try? data.write(to: fileURL, options: .atomic)
    }
}
