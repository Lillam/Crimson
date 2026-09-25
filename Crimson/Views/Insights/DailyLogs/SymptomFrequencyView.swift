//
//  SymptomFrequencyView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import Charts
import SwiftUI

/// How often each symptom turns up, worst first.
///
/// Horizontal bars because "Tender breasts" doesn't fit under a column, and
/// ranked because the answer people want is the top row.
///
/// Each bar wears the same tint as its chip on the day page, so a symptom is
/// recognisable across the two screens. The colour is redundant rather than
/// load-bearing — every bar is named on the axis and carries its own count —
/// which is what makes it safe for the paler tints to be hard to read.
struct SymptomFrequencyView: View {
    @Environment(DayLogStore.self) var days

    let scope: InsightsScope

    private struct Count: Identifiable {
        let symptom: DayLog.Symptom
        let days: Int
        var id: String { symptom.rawValue }
    }

    private var logs: [DayLog] {
        days.logs(since: scope.start())
    }

    /// Every symptom noted at least once, most days first.
    private var counts: [Count] {
        let logs = logs

        return DayLog.Symptom.allCases
            .map { symptom in
                Count(symptom: symptom, days: logs.count { $0.symptomSet.contains(symptom) })
            }
            .filter { $0.days > 0 }
            .sorted { $0.days > $1.days }
        }

    /// Bars need room to breathe but the card shouldn't run off the page.
    private var chartHeight: CGFloat {
        CGFloat(counts.count) * 26 + 10
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Symptoms")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.ink)
                    Text("Days each one was noted, \(scope.phrase)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.ink.opacity(0.75))
                }

                if counts.isEmpty {
                    Text("Nothing logged yet. Note how you're feeling on the day page and this fills in.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.ink.opacity(0.6))
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
                        .multilineTextAlignment(.center)
                } else {
                    Chart(counts) { count in
                        BarMark(
                            x: .value("Days", count.days),
                            y: .value("Symptom", count.symptom.title),
                            height: .fixed(14)
                        )
                        .foregroundStyle(count.symptom.tint)
                        .clipShape(.rect(bottomTrailingRadius: 4, topTrailingRadius: 4))
                        .annotation(position: .trailing, spacing: 6) {
                            Text("\(count.days)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColor.ink.opacity(0.75))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(preset: .aligned, position: .leading) { _ in
                            AxisValueLabel()
                                .font(.system(size: 11))
                                .foregroundStyle(AppColor.ink.opacity(0.75))
                        }
                    }
                    // The counts are labelled on each bar, so a bottom scale
                    // would just be a second copy of the same numbers.
                    .chartXAxis(.hidden)
                    .chartPlotStyle { $0.padding(.trailing, 20) }
                    .frame(height: chartHeight)
                }

                Text("Out of \(logs.count) \(logs.count == 1 ? "day" : "days") logged.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.ink.opacity(0.6))
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ScrollView {
        SymptomFrequencyView(scope: .twelveMonths)
            .padding(20)
    }
}
