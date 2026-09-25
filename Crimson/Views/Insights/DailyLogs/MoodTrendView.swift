//
//  MoodTrendView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import Charts
import SwiftUI

/// Mood and energy over time, averaged by month.
///
/// Monthly rather than daily: a year of daily points is 365 marks of noise,
/// and nobody reads a trend off that. The two share a 1–5 scale, so they sit
/// on one axis honestly — this is two series, not two scales.
struct MoodTrendView: View {
    @Environment(DayLogStore.self) var days

    let scope: InsightsScope

    private let calendar = Calendar.current

    private struct Point: Identifiable {
        let month: Date
        let series: String
        let average: Double
        var id: String { "\(series)-\(month.timeIntervalSince1970)" }
    }

    private static let mood = "Mood"
    private static let energy = "Energy"

    /// One point per series per month that has anything logged. Months with
    /// no logs are left out rather than drawn as zero, which would read as
    /// "felt terrible" instead of "wasn't tracking".
    private var points: [Point] {
        let logs = days.logs(since: scope.start())

        let byMonth = Dictionary(grouping: logs) { log in
            calendar.dateInterval(of: .month, for: log.date)?.start ?? log.date
        }

        return byMonth
            .sorted { $0.key < $1.key }
            .flatMap { month, logs -> [Point] in
                let moods = logs.compactMap { $0.mood?.value }
                let energies = logs.compactMap { $0.energy?.value }

                return [
                    moods.isEmpty ? nil : Point(
                        month: month,
                        series: Self.mood,
                        average: Double(moods.reduce(0, +)) / Double(moods.count)
                    ),
                    energies.isEmpty ? nil : Point(
                        month: month,
                        series: Self.energy,
                        average: Double(energies.reduce(0, +)) / Double(energies.count)
                    )
                ].compactMap { $0 }
            }
        }

    /// The months that actually have a point, oldest first.
    private var months: [Date] {
        Array(Set(points.map(\.month))).sorted()
    }

    /// The months to label. Twelve narrow labels collide on a phone, so long
    /// windows label every other one — driven off the real month values so a
    /// tick always sits under its point, which a `.stride` does not guarantee.
    private var labelledMonths: [Date] {
        let months = months
        let step = months.count > 7 ? 2 : 1
        return months.enumerated().compactMap { $0.offset % step == 0 ? $0.element : nil }
    }

    /// A line needs two points to be a line.
    private var hasTrend: Bool {
        months.count >= 2
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mood & energy")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.ink)
                    Text("Monthly average out of 5, \(scope.phrase)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.ink.opacity(0.75))
                }

                if !hasTrend {
                    Text("A trend needs at least two months with something logged.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.ink.opacity(0.6))
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                        .multilineTextAlignment(.center)
                } else {
                    Chart(points) { point in
                        LineMark(
                            x: .value("Month", point.month, unit: .month),
                            y: .value("Average", point.average)
                        )
                        .foregroundStyle(by: .value("Series", point.series))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Month", point.month, unit: .month),
                            y: .value("Average", point.average)
                        )
                        .foregroundStyle(by: .value("Series", point.series))
                        .symbolSize(60)
                    }
                    .chartForegroundStyleScale([
                        Self.mood: InsightsPalette.primary,
                        Self.energy: InsightsPalette.secondary
                    ])
                    .chartYScale(domain: 1...5)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                            AxisGridLine().foregroundStyle(AppColor.ink.opacity(0.08))
                            AxisValueLabel {
                                // The numbers mean nothing on their own, so the
                                // ends of the scale say what they stand for.
                                Text(scaleLabel(for: value.as(Int.self) ?? 0))
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.ink.opacity(0.6))
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: labelledMonths) { _ in
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                                .font(.system(size: 10))
                                .foregroundStyle(AppColor.ink.opacity(0.7))
                        }
                    }
                    .chartLegend(position: .bottom, alignment: .leading, spacing: 8)
                    .frame(height: 160)
                }
            }
        }
    }

    private func scaleLabel(for value: Int) -> String {
        switch value {
        case 1:  "Low"
        case 5:  "High"
        default: ""
        }
    }
}

#Preview(traits: .sampleData) {
    ScrollView {
        MoodTrendView(scope: .twelveMonths)
            .padding(20)
    }
}
