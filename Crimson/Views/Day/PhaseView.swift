//
//  PhaseView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

struct PhaseView: View {
    let position: CyclePosition
        
    private var isLate: Bool {
        position.daysLate > 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(isLate ? "Late" : position.phase.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text("· Day \(position.day) of ~\(position.cycleLength)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }
            Text(isLate
                 ? "\(position.daysLate) \(position.daysLate == 1 ? "day" : "days") past your usual cycle length."
                 : position.phase.summary)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(position.tint)
        .cornerRadius(12)
        .animation(.snappy(duration: 0.25), value: position.phase)
    }
}

#Preview("Phases") {
    /// `phase` is derived from `day`, so each state is just a different day of
    /// the same 28-day cycle. Day 31 is past the cycle length, which is what
    /// puts the card into its "Late" form.
    func position(onDay day: Int) -> CyclePosition {
        CyclePosition(day: day, cycleLength: 28, bleedLength: 4, cycleStart: Date())
    }

    return ScrollView {
        VStack(spacing: 10) {
            PhaseView(position: position(onDay: 2))   // Menstrual
            PhaseView(position: position(onDay: 6))   // Follicular
            PhaseView(position: position(onDay: 12))  // Fertile window
            PhaseView(position: position(onDay: 20))  // Luteal
            PhaseView(position: position(onDay: 31))  // Late — overrides to red
        }
        .padding(20)
    }
}
