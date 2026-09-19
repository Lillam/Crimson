//
//  InsightsView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @Environment(CycleStore.self) var store
    @Environment(ProfileStore.self) var profile
    
    private let calendar = Calendar.current
    private let engine = CycleEngine()
    
    /// Everything on this page is derived from the store's averages, so
    /// there's nothing to show until there are two periods to average.
    private var hasEnoughData: Bool {
        store.stats.averageCycleLength > 0
    }
    
    private var position: CyclePosition? {
        engine.position(on: Date(), from: store.stats)
    }
    
    private var nextPeriod: Date? {
        engine.nextPeriodStart(from: store.stats, onOrAfter: Date())
    }
    
    /// How much cycle lengths wander from the average, as a ± figure. The
    /// honest measure of "regular".
    private var cycleVariation: Int? {
        let lengths = store.cycleLengthHistory.map(\.days)
        
        guard let shortest = lengths.min(),
              let longest = lengths.max(), lengths.count >= 2
        else {
            return nil
        }
        
        return Int((Double(longest - shortest) / 2).rounded(.up))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Insights")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                Text(profile.displayName.map { "How your cycle's looking, \($0)." } ?? "How your cycle's looking.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.75))
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !hasEnoughData {
                        emptyState
                    } else {
                        if let position {
                            currentCycleCard(position)
                        }
                        statTiles
                        historyChart(
                            title: "Cycle length",
                            subtitle: "Days from one period start to the next",
                            samples: store.cycleLengthHistory,
                            average: store.stats.averageCycleLength
                        )
                        historyChart(
                            title: "Period length",
                            subtitle: "Days of bleeding each period",
                            samples: store.bleedLengthHistory,
                            average: store.stats.averageBleedLength
                        )
                        recentPeriods
                    }
                }
                .padding(.bottom, 80) // scroll clear of the floating tab bar
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // Top padding only: the scroll view must touch the bottom safe area
        // so it extends under it (and the tab bar) rather than being clipped.
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .background(.red)
    }
    
    // MARK: - Current cycle
    
    @ViewBuilder
    private func currentCycleCard(_ position: CyclePosition) -> some View {
        card {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current cycle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.75))
                        // The one hero number on the page.
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("Day \(position.day)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            Text("of ~\(position.cycleLength)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(position.daysLate > 0 ? "Late" : position.phase.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        if position.daysLate > 0 {
                            Text("\(position.daysLate) \(position.daysLate == 1 ? "day" : "days")")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                }
                
                phaseMeter(position)
                
                Text(position.daysLate > 0
                     ? "Past your usual cycle length with no period logged yet. Cycles vary — log it when it arrives."
                     : position.phase.summary)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.75))
                
                Text("Ovulation estimated day \(position.ovulationDay) · fertile days \(position.fertileDays.lowerBound)–\(position.fertileDays.upperBound). Estimates from your averages, not measurements.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
    }
    
    /// A meter across the whole cycle: one segment per phase, the current
    /// phase in full white and the rest in a lighter step of the same ink,
    /// with a marker on today. Labels sit under their own segments.
    @ViewBuilder
    private func phaseMeter(_ position: CyclePosition) -> some View {
        let total = Double(max(position.cycleLength, position.day))
        let isLate = position.daysLate > 0
        let gap: CGFloat = 2 // surface gap between segments
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let span: (Int) -> CGFloat = { days in
                max(CGFloat(days) / total * width - gap, 4)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .leading) {
                    HStack(spacing: gap) {
                        ForEach(CyclePhase.allCases, id: \.self) { phase in
                            Capsule()
                                .fill(.white.opacity(phase == position.phase && !isLate ? 1 : 0.35))
                                .frame(width: span(position.days(in: phase).count))
                        }
                        if isLate {
                            Capsule()
                                .fill(.white)
                                .frame(width: span(position.daysLate))
                        }
                    }
                    
                    // Today marker: ringed in the surface colour so it stays
                    // legible over any segment.
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().strokeBorder(.red, lineWidth: 2))
                        .offset(x: (CGFloat(position.day) - 0.5) / total * width - 6)
                }
                .frame(height: 12)
                
                HStack(spacing: gap) {
                    ForEach(CyclePhase.allCases, id: \.self) { phase in
                        let isCurrent = phase == position.phase && !isLate
                        Text(phase == .fertile ? "Fertile" : phase.title)
                            .font(.system(size: 10, weight: isCurrent ? .semibold : .regular))
                            .foregroundColor(.white.opacity(isCurrent ? 1 : 0.6))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(width: span(position.days(in: phase).count), alignment: .leading)
                    }
                    if isLate {
                        Text("Late")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: span(position.daysLate), alignment: .leading)
                    }
                }
            }
        }
        .frame(height: 32)
    }
    
    // MARK: - Stat tiles
    
    private var statTiles: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        
        return LazyVGrid(columns: columns, spacing: 10) {
            statTile("Average cycle", value: "\(store.stats.averageCycleLength)", unit: "days")
            statTile("Average period", value: "\(store.stats.averageBleedLength)", unit: "days")
            
            if let nextPeriod {
                let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: nextPeriod).day ?? 0
                statTile(
                    "Next period",
                    value: nextPeriod.formatted(.dateTime.day().month(.abbreviated)),
                    unit: days == 0 ? "today" : "in \(days) \(days == 1 ? "day" : "days")"
                )
            }
            
            if let cycleVariation {
                statTile(
                    "Variation",
                    value: "±\(cycleVariation)",
                    unit: cycleVariation <= 3 ? "days · regular" : "days · varies"
                )
            } else {
                statTile("Cycles logged", value: "\(store.cycleLengthHistory.count)", unit: "so far")
            }
        }
    }
    
    @ViewBuilder
    private func statTile(_ label: String, value: String, unit: String) -> some View {
        card {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
                Text(value)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - History charts
    
    /// A column per period, latest emphasised, average as a rule. Tap a
    /// column to read its value; otherwise only the latest is labelled.
    @ViewBuilder
    private func historyChart(title: String, subtitle: String, samples: [CycleSample], average: Int) -> some View {
        let recent = Array(samples.suffix(12))
        
        card {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                }
                
                if recent.count < 2 {
                    Text("A trend can't be found until at least 2 cycles tracked, 1 cycle = 2 periods, 3 periods = 2 cycles, 4 periods = 3 cycles and so forth.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                } else {
                    HistoryChart(samples: recent, average: average)
                        .frame(height: 160)
                }
            }
        }
    }
    
    // MARK: - Recent periods
    
    private var recentPeriods: some View {
        card {
            VStack(alignment: .leading, spacing: 0) {
                Text("Recent periods")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                ForEach(Array(store.recentRecords.prefix(6).enumerated()), id: \.element.id) { index, record in
                    if index > 0 {
                        Divider().overlay(.white.opacity(0.25))
                    }
                    HStack {
                        Text(record.startDate.formatted(.dateTime.day().month(.abbreviated).year()))
                            .foregroundColor(.white)
                        Spacer()
                        Text(record.isOngoing
                             ? "Ongoing"
                             : "\(record.bleedLength ?? 0) \(record.bleedLength == 1 ? "day" : "days")")
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .font(.system(size: 14))
                    .padding(.vertical, 10)
                }
            }
        }
    }
    
    // MARK: - Empty state
    
    private var emptyState: some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                Text("Nothing to show yet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text("Insights are built from your averages, so they appear once two periods have been logged. Use Log period on the calendar to add them — past ones count too.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }
    
    // MARK: - Card
    
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.05))
            .cornerRadius(12)
    }
}

/// Column chart of one number per period, on the app's red surface: the
/// latest column in full white, the rest in a lighter step, a hairline for
/// the average, and a tap-to-read label.
private struct HistoryChart: View {
    let samples: [CycleSample]
    let average: Int
    
    @State private var selectedLabel: String?
    
    /// Categorical x-axis: one evenly spaced slot per period, labelled by
    /// its start date, rather than a time axis that spreads and clips them.
    private func label(for sample: CycleSample) -> String {
        sample.start.formatted(.dateTime.day().month(.abbreviated))
    }
    
    /// The column whose value is shown: the tapped one, else the latest.
    private var labelled: CycleSample? {
        samples.first { label(for: $0) == selectedLabel } ?? samples.last
    }
    
    var body: some View {
        Chart {
            ForEach(samples) { sample in
                BarMark(
                    x: .value("Period", label(for: sample)),
                    y: .value("Days", sample.days),
                    width: .fixed(18)
                )
                .foregroundStyle(.white.opacity(sample.id == labelled?.id ? 1 : 0.45))
                .clipShape(.rect(topLeadingRadius: 4, topTrailingRadius: 4))
                .annotation(position: .top, spacing: 4) {
                    if sample.id == labelled?.id {
                        Text("\(sample.days)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            RuleMark(y: .value("Average", average))
                .foregroundStyle(.white.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .annotation(position: .trailing, alignment: .leading, spacing: 4) {
                    Text("avg")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }
        }
        .chartXSelection(value: $selectedLabel)
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 10))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(.white.opacity(0.15))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 10))
            }
        }
        .chartYScale(domain: 0...max((samples.map(\.days).max() ?? 0) + 4, average + 4))
        .chartPlotStyle { $0.padding(.trailing, 24) }
    }
}

#Preview {
    InsightsView()
        .environment(CycleStore())
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
}
