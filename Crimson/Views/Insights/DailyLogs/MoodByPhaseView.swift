//
//  MoodByPhaseView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import Charts
import SwiftUI

/// Average mood in each phase of the cycle.
///
/// The one card where the day logs and the cycle history actually meet, and
/// the question the app exists to answer: does mood drop in the luteal phase,
/// the way PMS is supposed to?
///
/// One hue, like the symptom chart — a single measure, with the phase names on
/// the axis carrying identity. The phase colours used elsewhere can't be
/// reused here: four steps across red-to-purple aren't separable at the
/// lightness chart marks need, for normal or colour-blind vision.
struct MoodByPhaseView: View {
    @Environment(DayLogStore.self) var days
    @Environment(CycleStore.self) var cycles

    let scope: InsightsScope

    private struct Average: Identifiable {
        let phase: CyclePhase
        let mood: Double
        let days: Int
        var id: String { phase.title }
    }

    /// Every phase that has at least one logged mood, in cycle order so the
    /// chart reads as a journey through the cycle rather than a ranking.
    private var averages: [Average] {
        let logs = days.logs(since: scope.start())

        var totals: [CyclePhase: (sum: Int, count: Int)] = [:]

        for log in logs {
            guard
                let mood = log.mood?.value,
                let phase = cycles.phase(on: log.date)
            else {
                continue
            }

            let running = totals[phase] ?? (0, 0)
            totals[phase] = (running.sum + mood, running.count + 1)
        }

        return CyclePhase.allCases.compactMap { phase in
            guard let total = totals[phase], total.count > 0 else {
                return nil
            }

            return Average(
                phase: phase,
                mood: Double(total.sum) / Double(total.count),
                days: total.count
            )
        }
        }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mood by phase")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.ink)
                    Text("Average mood out of 5 in each phase, \(scope.phrase)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.ink.opacity(0.75))
                }

                let averages = averages

                if averages.count < 2 {
                    Text("This needs a few logged days spread across a cycle. Keep noting how you feel and it'll fill in.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.ink.opacity(0.6))
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                        .multilineTextAlignment(.center)
                } else {
                    Chart(averages) { average in
                        BarMark(
                            x: .value("Phase", average.phase.title),
                            y: .value("Mood", average.mood),
                            width: .fixed(28)
                        )
                        .foregroundStyle(InsightsPalette.primary)
                        .clipShape(.rect(topLeadingRadius: 4, topTrailingRadius: 4))
                        .annotation(position: .top, spacing: 4) {
                            Text(average.mood, format: .number.precision(.fractionLength(1)))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColor.ink.opacity(0.75))
                        }
                    }
                    .chartYScale(domain: 0...5)
                    .chartYAxis {
                        AxisMarks(values: [0, 5]) { _ in
                            AxisGridLine().foregroundStyle(AppColor.ink.opacity(0.08))
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .font(.system(size: 10))
                                .foregroundStyle(AppColor.ink.opacity(0.75))
                        }
                    }
                    .frame(height: 160)

                    if let lowest = averages.min(by: { $0.mood < $1.mood }) {
                        Text("Lowest in \(lowest.phase.title.lowercased()), across \(lowest.days) logged \(lowest.days == 1 ? "day" : "days").")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.ink.opacity(0.6))
                    }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ScrollView {
        MoodByPhaseView(scope: .twelveMonths)
            .padding(20)
    }
}
