//
//  HistoryChartView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import Charts
import SwiftUI

struct HistoryChartView: View {
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
                .foregroundStyle(.red.opacity(sample.id == labelled?.id ? 1 : 0.45))
                .clipShape(.rect(topLeadingRadius: 4, topTrailingRadius: 4))
                .annotation(position: .top, spacing: 4) {
                    if sample.id == labelled?.id {
                        Text("\(sample.days)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
            }
            
            RuleMark(y: .value("Average", average))
                .foregroundStyle(.red.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .annotation(position: .trailing, alignment: .leading, spacing: 4) {
                    Text("avg")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.ink.opacity(0.7))
                }
        }
        .chartXSelection(value: $selectedLabel)
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(AppColor.ink.opacity(0.7))
                    .font(.system(size: 10))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(AppColor.ink.opacity(0.15))
                AxisValueLabel()
                    .foregroundStyle(AppColor.ink.opacity(0.7))
                    .font(.system(size: 10))
            }
        }
        .chartYScale(domain: 0...max((samples.map(\.days).max() ?? 0) + 4, average + 4))
        .chartPlotStyle { $0.padding(.trailing, 24) }
    }
}
