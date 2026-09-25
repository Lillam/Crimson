//
//  DayLogStore.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import SwiftData
import Foundation

@Observable
final class DayLogStore {
    private let context: ModelContext

    private(set) var logs: [String: DayLog] = [:]

    init(context: ModelContext) {
        self.context = context
        reload()
    }

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
        logs = Dictionary(fetched.map {
            (key(for: $0.date), $0)
        }) { _, latest in latest }
    }

    private func reload() {
        let fetched = (try? context.fetch(
            FetchDescriptor<DayLog>(sortBy: [SortDescriptor(\.storedDate)])
        )) ?? []

        logs = Dictionary(fetched.map {
            (key(for: $0.date), $0)
        }) { _, latest in latest }
    }

    private func key(for date: Date) -> String {
        date.formatted(DateFormat.calendarDay)
    }

    func entry(for date: Date) -> DayLog {
        logs[key(for: date)] ?? DayLog(date: date)
    }

    func logs(since date: Date) -> [DayLog] {
        let cutoff = CalendarDay.stored(from: date)

        return logs.values
            .filter { $0.storedDate >= cutoff }
            .sorted { $0.storedDate < $1.storedDate }
    }

    func hasEntry(on date: Date) -> Bool {
        logs[key(for: date)] != nil
    }

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
