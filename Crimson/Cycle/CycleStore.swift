//
//  CycleStore.swift
//  Crimson
//
//  Created by Liam Taylor on 08/06/2026.
//

import Foundation

@Observable
final class CycleStore {
    private let calendar = Calendar.current

    /// this is just dummy data for the period tracker based on my partner's current
    /// menstrual cycles for the time being.
    var records: [CycleRecord] = [
        CycleRecord(startDate: toDate("2026-05-11"), endDate: toDate("2026-05-15")),
        CycleRecord(startDate: toDate("2026-06-10"), endDate: toDate("2026-06-13")),
        CycleRecord(startDate: toDate("2026-07-09"), endDate: toDate("2026-07-12")),
        CycleRecord(startDate: toDate("2026-08-05"), endDate: toDate("2026-08-08")),
        CycleRecord(startDate: toDate("2026-09-04"), endDate: toDate("2026-09-07"))
    ]
    
    /// Records ordered oldest → newest. Cycle length is measured between
    /// consecutive starts, so the order matters regardless of how the records
    /// were logged.
    private var sortedRecords: [CycleRecord] {
        records.sorted { $0.startDate < $1.startDate }
    }
    
    /// The averages the engine remembers. These are derived from *every* record
    /// ever logged — however long ago — so once a user stops logging, the last
    /// known averages keep being applied to every future month.
    var stats: CycleStats {
        let sorted = sortedRecords
        var cycleLengths: [Int] = []
        var bleedLengths: [Int] = []
        
        sorted.enumerated().forEach { index, record in
            if let bleedLength = record.bleedLength {
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
            lastPeriod: sorted.last?.startDate
        )
    }
    
    // MARK: - History
    
    /// Length of each completed cycle, keyed on the period that started it.
    /// The most recent period has no next start yet, so it's not included.
    var cycleLengthHistory: [CycleSample] {
        let sorted = sortedRecords
        return zip(sorted, sorted.dropFirst()).compactMap { record, next in
            getCycleLengthFromRecords(from: next, to: record).map {
                CycleSample(id: record.id, start: record.startDate, days: $0)
            }
        }
    }
    
    /// Length of each finished period.
    var bleedLengthHistory: [CycleSample] {
        sortedRecords.compactMap { record in
            record.bleedLength.map { CycleSample(id: record.id, start: record.startDate, days: $0) }
        }
    }
    
    /// Newest first, for a "recent periods" list.
    var recentRecords: [CycleRecord] {
        sortedRecords.reversed()
    }
    
    // MARK: - Lookups
    
    /// The period that has been started but not yet ended, if there is one.
    var openRecord: CycleRecord? {
        records.first { $0.isOngoing }
    }
    
    /// The logged period covering `date`, if any.
    func record(containing date: Date) -> CycleRecord? {
        records.first { $0.contains(date) }
    }
    
    // MARK: - Logging
    
    /// Logs a period running from `start` to `end` inclusive. Pass `nil` for
    /// `end` to log a period that's still ongoing. Any existing records that
    /// overlap or sit directly next to the new range are folded into it, so a
    /// user can never end up with two records for the same days.
    @discardableResult
    func logPeriod(from start: Date, to end: Date?) -> CycleRecord {
        var start = calendar.startOfDay(for: start)
        var end = end.map { calendar.startOfDay(for: $0) }
        
        // Tolerate the range being given back-to-front.
        if let unwrappedEnd = end, unwrappedEnd < start {
            (start, end) = (unwrappedEnd, start)
        }
        
        let rangeEnd = end ?? max(start, calendar.startOfDay(for: Date()))
        let touching = records.filter { record in
            let recordStart = calendar.startOfDay(for: record.startDate)
            let recordEnd = calendar.startOfDay(for: record.effectiveEndDate)
            // Overlapping, or adjacent (one ends the day before the other starts).
            return recordStart <= dayAfter(rangeEnd) && recordEnd >= dayBefore(start)
        }
        
        let mergedStart = ([start] + touching.map { calendar.startOfDay(for: $0.startDate) }).min() ?? start
        let mergedEnd: Date? = end.map { end in
            ([end] + touching.compactMap { $0.endDate.map(calendar.startOfDay) }).max() ?? end
        }
        
        let merged = CycleRecord(startDate: mergedStart, endDate: mergedEnd)
        records.removeAll { record in touching.contains { $0.id == record.id } }
        insert(merged)
        return merged
    }
    
    /// Closes the currently open period on `date`. Does nothing if no period is open.
    func endPeriod(on date: Date) {
        guard let open = openRecord else {
            return
        }
        
        update(open, start: open.startDate, end: date)
    }
    
    /// Replaces `record`'s dates, merging with neighbours the same way `logPeriod` does.
    func update(_ record: CycleRecord, start: Date, end: Date?) {
        delete(record)
        logPeriod(from: start, to: end)
    }
    
    func delete(_ record: CycleRecord) {
        records.removeAll { $0.id == record.id }
    }
    
    private func insert(_ record: CycleRecord) {
        records.append(record)
        records.sort { $0.startDate < $1.startDate }
    }
    
    private func dayBefore(_ date: Date) -> Date {
        calendar.date(byAdding: .day, value: -1, to: date) ?? date
    }
    
    private func dayAfter(_ date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }
    
    // MARK: - Stats helpers
    
    /// helpers for the internal class which will be for building what the store needs.
    /// here we're just going to be looking at getting the cycle duration — bleed
    /// length lives on `CycleRecord` itself.
    
    /// Whole calendar days between two consecutive period starts. Uses the
    /// calendar rather than dividing seconds so daylight-saving changes can't
    /// shave a day off a cycle.
    private func getCycleLengthFromRecords(from end: CycleRecord, to start: CycleRecord?) -> Int? {
        guard let starting = start else {
            return nil
        }
        
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: starting.startDate),
            to: calendar.startOfDay(for: end.startDate)
        ).day
    }
}

/// One data point for the history charts: a period start and a number of days.
struct CycleSample: Identifiable {
    let id: UUID
    let start: Date
    let days: Int
}
