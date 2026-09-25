//
//  HistoryChartBoxView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct HistoryChartBoxView: View {
    let title: String
    let subtitle: String
    let samples: [CycleSample]
    let average: Int
    
    private var recent: [CycleSample] {
        Array(samples.suffix(12))
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.ink)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.ink.opacity(0.75))
                }
                
                if recent.count < 2 {
                    Text("A trend can't be found until at least 2 cycles tracked, 1 cycle = 2 periods, 3 periods = 2 cycles, 4 periods = 3 cycles and so forth.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.ink.opacity(0.6))
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                } else {
                    HistoryChartView(samples: recent, average: average)
                        .frame(height: 160)
                }
            }
        }
    }
}
