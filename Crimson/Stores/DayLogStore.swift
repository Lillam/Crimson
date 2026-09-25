//
//  DayLogStore.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import Foundation
import SwiftData

/// The day logs, keyed by calendar day so the day page can look one up without
/// a fetch per render.
@Observable
final class DayLogStore {
    private let context: ModelContext

    private(set) var logs: [String: DayLog] = [:]

    init(context: ModelContext) {
        self.context = context
        reload()
    }

    /// Load data for a specific set of months, we don't want to be loading an entire set of data into
    /// memory as that will start consuming lots of memory the more that the user starts utilising
    /// the application.
    /// instead what we're going to do is load day data from start to end loading in (x) months at
    /// any given time and have that data shifted out as they scroll through their days.
    private func load(from start: Date, to end: Date) {
        let lower = CalendarDay.stored(from: start)
        let upper = CalendarDay.stored(from: end)
        
        let fetched = (try? context.fetch(
            FetchDescriptor<DayLog>(
                predicate: #Predicate { $0.storedDate >= lower && $0.storedDate < upper },
                sortBy: [SortDescriptor(\.storedDate)]
            )
        )) ?? []
        
        // Rebuilt rather than merged, so a deleted day doesn't linger.
        logs = Dictionary(fetched.map { (key(for: $0.date), $0) }) { _, latest in latest }
    }

    private func reload() {
        print("loaded the day log store")
        // Sorted on `storedDate`, not `date`: `date` is computed, so it isn't
        // in the schema and sorting on it is a fatal error rather than a
        // throw — `try?` wouldn't save us.
        let fetched = (try? context.fetch(
            FetchDescriptor<DayLog>(sortBy: [SortDescriptor(\.storedDate)])
        )) ?? []

        // Rebuilt rather than merged, so a deleted day doesn't linger.
        logs = Dictionary(fetched.map { (key(for: $0.date), $0) }) { _, latest in latest }
    }

    /// Days are keyed as "yyyy-MM-dd" in the local calendar, so an entry
    /// stays on the day it was written regardless of time zone changes.
    private func key(for date: Date) -> String {
        date.formatted(DateFormat.calendarDay)
    }

    /// The log for `date`, or a blank one if nothing's been noted yet.
    ///
    /// The blank is deliberately *not* inserted: opening a day shouldn't
    /// create a row for it. `update(for:_:)` is what commits one.
    func entry(for date: Date) -> DayLog {
        logs[key(for: date)] ?? DayLog(date: date)
    }

    func hasEntry(on date: Date) -> Bool {
        logs[key(for: date)] != nil
    }

    /// Applies a change to the day's log, creating the row on first write and
    /// dropping it again if the change leaves nothing on the day.
    func update(for date: Date, _ change: (DayLog) -> Void) {
        let key = key(for: date)
        let log: DayLog

        if let existing = logs[key] {
            log = existing
        } else {
            log = DayLog(date: date)
            context.insert(log)
            logs[key] = log
        }

        // `DayLog` is a class, so this mutates the stored object directly —
        // there's nothing to write back.
        change(log)

        if log.isEmpty {
            context.delete(log)
            logs[key] = nil
        }

        save()
    }

    func delete(on date: Date) {
        guard let log = logs[key(for: date)] else {
            return
        }

        context.delete(log)
        logs[key(for: date)] = nil
        save()
    }
    
    func clear() {
        do {
            try context.delete(model: DayLog.self)
        } catch {
            assertionFailure("Could not clear the day log: \(error)")
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            // A lost day log can't be recovered from anywhere, so this is loud
            // in debug. It wants surfacing in the UI eventually.
            assertionFailure("Could not save the day log: \(error)")
        }
    }
}
