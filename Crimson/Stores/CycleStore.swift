//
//  CycleStore.swift
//  Crimson
//
//  Created by Liam Taylor on 08/06/2026.
//

import Foundation
import SwiftData

/// What came of trying to log a period. An overlap isn't a failure — it's
/// an ordinary thing for someone to do — so it comes back as a result the
/// caller can put in front of the user, rather than as a thrown error.
/// `throws` on these methods means the database write itself went wrong.
enum LogOutcome {
    case logged(Cycle)
    case clashes(with: Cycle)
}

@Observable final class CycleStore : Store<Cycle> {
    private let calendar = Calendar.current

    /// this is just dummy data for the period tracker based on my partner's current
    /// menstrual cycles for the time being.
    var records: [Cycle] = []

    /// The averages the engine remembers. These are derived from *every* record
    /// ever logged — however long ago — so once a user stops logging, the last
    /// known averages keep being applied to every future month.
    ///
    /// Recomputed on load rather than on read: it walks every record, and it's
    /// read once per day log by `phase(on:)`, which made building the insights
    /// charts quadratic in the amount of data.
    private(set) var stats: CycleStats = CycleStats(
        averageCycleLength: 0,
        averageBleedLength: 0,
        lastPeriod: nil
    )
    
    override func load() {
        records = (try? context.fetch(
            FetchDescriptor<Cycle>(sortBy: [SortDescriptor(\.storedStart)])
        )) ?? []
        
        stats = makeStats()
    }
    
    /// Records ordered oldest → newest. Cycle length is measured between
    /// consecutive starts, so the order matters regardless of how the records
    /// were logged.
    private var sortedRecords: [Cycle] {
        records.sorted { $0.start < $1.start }
    }
    
    private func makeStats() -> CycleStats {
        let sorted = sortedRecords
        var cycleLengths: [Int] = []
        var bleedLengths: [Int] = []
        
        sorted.enumerated().forEach { index, record in
            if let bleedLength = record.length {
                bleedLengths.append(bleedLength)
            }
                        
            if let cycleLength = getCycleLengthFromRecords(
                from: record,
                to: index == 0 ? nil : sorted[index - 1]
            ) {
                cycleLengths.append(cycleLength)
            }
        }
        
        return CycleStats(
            /// this dicates how many days the next period will start from.
            averageCycleLength: cycleLengths.average,
            /// this dictates how long the period will last for.
            averageBleedLength: bleedLengths.average,
            /// their last period start — we're going to utilise this for the
            /// projection into the future. Cycle length is measured start-to-start,
            /// so the engine adds averageCycleLength repeatedly from this date to
            /// acquire what the projection might look like.
            lastPeriod: sorted.last?.start
        )
    }
    
    // MARK: - History
    
    /// Length of each completed cycle, keyed on the period that started it.
    /// The most recent period has no next start yet, so it's not included.
    var cycleLengthHistory: [CycleSample] {
        let sorted = sortedRecords
        return zip(sorted, sorted.dropFirst()).compactMap { record, next in
            getCycleLengthFromRecords(from: next, to: record).map {
                CycleSample(id: record.id, start: record.start, days: $0)
            }
        }
    }
    
    /// Length of each finished period.
    var bleedLengthHistory: [CycleSample] {
        sortedRecords.compactMap { record in
            record.length.map { CycleSample(id: record.id, start: record.start, days: $0) }
        }
    }
    
    /// Newest first, for a "recent periods" list.
    var recentRecords: [Cycle] {
        sortedRecords.reversed()
    }
    
    // MARK: - Lookups
    
    /// The period that has been started but not yet ended, if there is one.
    var openRecord: Cycle? {
        records.first { $0.isOngoing }
    }
    
    /// Which phase `date` fell in, worked out from the logged period that
    /// started most recently before it.
    ///
    /// `CycleEngine.position(on:from:)` can't answer this: it guards on
    /// `day >= lastPeriod` and projects forward, so every historical day comes
    /// back nil. Here the day is placed against the cycle it actually fell in.
    func phase(on date: Date) -> CyclePhase? {
        let day = calendar.startOfDay(for: date)

        guard
            stats.averageCycleLength > 0,
            let cycle = records.last(where: { calendar.startOfDay(for: $0.start) <= day })
        else {
            return nil
        }

        let start = calendar.startOfDay(for: cycle.start)
        let offset = calendar.dateComponents([.day], from: start, to: day).day ?? 0

        // A day far past its cycle start means a gap in logging rather than a
        // very long cycle, and placing it in a phase would be guesswork.
        guard offset >= 0, offset < stats.averageCycleLength else {
            return nil
        }

        return CyclePosition(
            day: offset + 1,
            cycleLength: stats.averageCycleLength,
            bleedLength: cycle.length ?? stats.averageBleedLength,
            cycleStart: start
        ).phase
    }

    /// The logged period covering `date`, if any.
    func record(containing date: Date) -> Cycle? {
        records.first { $0.contains(date) }
    }
    
    /// Logs a period running from `start` to `end` inclusive. Pass `nil` for
    /// `end` to log a period that's still ongoing. A range that overlaps a
    /// period already logged is refused rather than merged into it, so the
    /// user gets told instead of silently having two entries rewritten.
    @discardableResult
    func logPeriod(from start: Date, to end: Date?) throws -> LogOutcome {
        let (start, end) = ordered(start, end)
        
        if let existing = clash(from: start, to: end, ignoring: nil) {
            return .clashes(with: existing)
        }
        
        let cycle = Cycle(start: start, end: end)
        try insert(cycle)
        
        return .logged(cycle)
    }
    
    /// Closes the currently open period on `date`. Returns nil if no period
    /// is open, so "nothing to end" reads differently from "couldn't end it".
    @discardableResult
    func endPeriod(on date: Date) throws -> LogOutcome? {
        guard let open = openRecord else {
            return nil
        }
        
        return try update(open, start: open.start, end: date)
    }
    
    /// Moves `record` to a new range.
    ///
    /// The range is checked *before* anything is written, so a clash leaves
    /// the record exactly as it was. The dates are edited in place rather than
    /// deleted and re-inserted, which keeps the record's id — the charts key
    /// their samples on it.
    @discardableResult
    func update(_ record: Cycle, start: Date, end: Date?) throws -> LogOutcome {
        let (start, end) = ordered(start, end)
        
        if let existing = clash(from: start, to: end, ignoring: record) {
            return .clashes(with: existing)
        }
        
        record.start = start
        record.end = end
        
        try context.save()
        reload()
        
        return .logged(record)
    }
    
    /// The first logged period covering any of these days. `editing` is left
    /// out of the search — a record being moved can't clash with itself.
    private func clash(from start: Date, to end: Date?, ignoring editing: Cycle?) -> Cycle? {
        let rangeEnd = end ?? max(start, calendar.startOfDay(for: Date()))
        
        return records.first {
            $0.id != editing?.id && $0.overlaps(start, through: rangeEnd)
        }
    }
    
    func delete(_ record: Cycle) throws {
        context.delete(record)
        try context.save()
        reload()
    }
}

/// One data point for the history charts: a period start and a number of days.
struct CycleSample: Identifiable {
    let id: UUID
    let start: Date
    let days: Int
}
