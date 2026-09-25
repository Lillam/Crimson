//
//  CurrentCycleView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct CurrentCycleView: View {
    let position: CyclePosition?
    
    var body: some View {
        if let position {
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Cycle")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.black.opacity(0.75))
                            // The one hero number on the page.
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("Day \(position.day)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.black)
                                Text("of ~\(position.cycleLength)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black.opacity(0.75))
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(position.daysLate > 0 ? "Late" : position.phase.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            if position.daysLate > 0 {
                                Text("\(position.daysLate) \(position.daysLate == 1 ? "day" : "days")")
                                    .font(.system(size: 13))
                                    .foregroundColor(.black.opacity(0.75))
                            }
                        }
                    }
                    
                    CurrentCyclePhaseMetreView(position: position)
                    
                    Text(position.daysLate > 0
                         ? "Past your usual cycle length with no period logged yet. Cycles vary — log it when it arrives."
                         : position.phase.summary)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
                    
                    Text("Ovulation estimated day \(position.ovulationDay) · fertile days \(position.fertileDays.lowerBound)–\(position.fertileDays.upperBound). Estimates from your averages, not measurements.")
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.55))
                }
            }
        }
    }
}
