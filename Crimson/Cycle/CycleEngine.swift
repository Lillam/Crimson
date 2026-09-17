//
//  CycleEngine.swift
//  Crimson
//
//  Created by Liam Taylor on 08/06/2026.
//

import Foundation

class CycleEngine {
    private let calendar = Calendar.current

    /// Projects the days the individual is likely to be bleeding, from the most
    /// recent recorded period up to (and including) `date`.
    ///
    /// Each future cycle starts `averageCycleLength` days after the previous one,
    /// and each bleed lasts `averageBleedLength` days. We return every individual
    /// day inside those future bleed windows so the caller can filter them down to
    /// whichever month(s) it wants to display.
    ///
    /// The projection is open-ended: it doesn't matter how long ago the last
    /// period was logged — the stored averages are applied cycle after cycle
    /// until the horizon is reached.
    ///
    /// This needs a slight alteration where if the range between two dates are too large
    /// then it needs to defacto back to an average 4 week cycle again as it's too large of
    /// a gap and no one's cycle is > 2 months on average.
    func createProjection(from stats: CycleStats, for date: Date) -> [Date] {
        let bleedLength = max(stats.averageBleedLength, 1)
        let horizon = calendar.startOfDay(for: date)
        var projectedDays: [Date] = []

        for periodStart in projectedPeriodStarts(from: stats) {
            if periodStart > horizon {
                break
            }

            // Add each bleeding day of this cycle that falls within the horizon.
            for offset in 0..<bleedLength {
                guard let day = calendar.date(byAdding: .day, value: offset, to: periodStart) else {
                    continue
                }
                
                if day > horizon {
                    break
                }
                
                projectedDays.append(day)
            }
        }

        return projectedDays
    }

    /// The first projected period start on or after `date` — i.e. the answer to
    /// "when is my next period?" from any given day.
    func nextPeriodStart(from stats: CycleStats, onOrAfter date: Date) -> Date? {
        let day = calendar.startOfDay(for: date)
        return projectedPeriodStarts(from: stats).first { $0 >= day }
    }

    /// Whole days from `date` until the next projected period starts. `0` means
    /// it's projected to start that day.
    func daysUntilNextPeriod(from stats: CycleStats, on date: Date) -> Int? {
        guard let next = nextPeriodStart(from: stats, onOrAfter: date) else {
            return nil
        }
        
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: next).day
    }

    /// Where `date` sits within its cycle — which day it is, how long the
    /// cycle is expected to be, and which phase that puts it in. Works for
    /// any date on or after the last logged period, including projected
    /// future cycles. Nil if there's no history to go on.
    func position(on date: Date, from stats: CycleStats) -> CyclePosition? {
        guard let lastPeriodStart = stats.lastPeriod, stats.averageCycleLength > 0 else {
            return nil
        }
        
        let day = calendar.startOfDay(for: date)
        let anchor = calendar.startOfDay(for: lastPeriodStart)
        guard day >= anchor else {
            return nil
        }
        
        // The most recent cycle start on or before `date`: the last logged
        // period, or one of the projected ones after it.
        var cycleStart = anchor
        for start in projectedPeriodStarts(from: stats) {
            if start > day { break }
            cycleStart = start
        }
        
        let dayNumber = (calendar.dateComponents([.day], from: cycleStart, to: day).day ?? 0) + 1
        return CyclePosition(
            day: dayNumber,
            cycleLength: stats.averageCycleLength,
            bleedLength: max(stats.averageBleedLength, 1),
            cycleStart: cycleStart
        )
    }

    /// An infinite, lazy sequence of projected period start dates: the last
    /// logged period start plus one, two, three… average cycles. Empty if we
    /// don't yet know a cycle length.
    private func projectedPeriodStarts(from stats: CycleStats) -> some Sequence<Date> {
        guard let lastPeriodStart = stats.lastPeriod, stats.averageCycleLength > 0 else {
            return AnySequence<Date>([])
        }

        // `stats.lastPeriod` is the start of the most recent bleed; cycle length
        // is measured start-to-start, so we step forward from here.
        let anchor = calendar.startOfDay(for: lastPeriodStart)
        let calendar = self.calendar

        return AnySequence((1...).lazy.compactMap { cycle in
            calendar.date(byAdding: .day, value: cycle * stats.averageCycleLength, to: anchor)
        })
    }
}

enum CyclePhase: CaseIterable {
    case menstrual, follicular, fertile, luteal
    
    var title: String {
        switch self {
        case .menstrual:  "Menstrual"
        case .follicular: "Follicular"
        case .fertile:    "Fertile window"
        case .luteal:     "Luteal"
        }
    }
    
    /// One line of what the phase typically means, for context on screen.
    var summary: String {
        switch self {
        case .menstrual:  "Your period. Energy is often lowest around now."
        case .follicular: "Post-period. Energy and mood tend to climb."
        case .fertile:    "The days around estimated ovulation."
        case .luteal:     "Pre-period. PMS symptoms are most common here."
        }
    }
}

/// A day's place in its cycle, with the phase boundaries that come from the
/// standard model: ovulation ≈ 14 days before the next period, the fertile
/// window the five days before it through the day after. All estimates.
struct CyclePosition {
    let day: Int
    let cycleLength: Int
    let bleedLength: Int
    let cycleStart: Date
    
    var ovulationDay: Int {
        max(cycleLength - 14, bleedLength + 1)
    }
    
    var menstrualDays: ClosedRange<Int> { 1...bleedLength }
    var fertileDays: ClosedRange<Int> { max(ovulationDay - 5, bleedLength + 1)...min(ovulationDay + 1, cycleLength) }
    
    var phase: CyclePhase {
        switch day {
        case menstrualDays: .menstrual
        case fertileDays:   .fertile
        case ..<fertileDays.lowerBound: .follicular
        default: .luteal
        }
    }
    
    /// Positive once the cycle has run past its expected length with no new
    /// period logged.
    var daysLate: Int {
        max(day - cycleLength, 0)
    }
    
    func days(in phase: CyclePhase) -> ClosedRange<Int> {
        switch phase {
        case .menstrual:  menstrualDays
        case .follicular: (bleedLength + 1)...max(fertileDays.lowerBound - 1, bleedLength + 1)
        case .fertile:    fertileDays
        case .luteal:     min(fertileDays.upperBound + 1, cycleLength)...cycleLength
        }
    }
}
