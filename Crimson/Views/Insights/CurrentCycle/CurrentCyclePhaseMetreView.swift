//
//  CurrentCyclePhaseMetreView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct CurrentCyclePhaseMetreView: View {
    let position: CyclePosition
    
    private var total: Double {
        Double(max(position.cycleLength, position.day))
    }
    
    private var isLate: Bool {
        position.daysLate > 0
    }
    
    let gap: CGFloat = 2
        
    var body: some View {
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
                                .fill(.red.opacity(phase == position.phase && !isLate ? 1 : 0.35))
                                .frame(width: span(position.days(in: phase).count))
                        }
                        if isLate {
                            Capsule()
                                .fill(AppColor.card)
                                .frame(width: span(position.daysLate))
                        }
                    }
                    
                    // Today marker: ringed in the surface colour so it stays
                    // legible over any segment.
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().strokeBorder(AppColor.card, lineWidth: 2))
                        .offset(x: (CGFloat(position.day) - 0.5) / total * width - 6)
                }
                .frame(height: 12)
                
                HStack(spacing: gap) {
                    ForEach(CyclePhase.allCases, id: \.self) { phase in
                        let isCurrent = phase == position.phase && !isLate
                        Text(phase == .fertile ? "Fertile" : phase.title)
                            .font(.system(size: 10, weight: isCurrent ? .semibold : .regular))
                            .foregroundColor(AppColor.ink.opacity(isCurrent ? 1 : 0.6))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(width: span(position.days(in: phase).count), alignment: .leading)
                    }
                    if isLate {
                        Text("Late")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppColor.ink)
                            .frame(width: span(position.daysLate), alignment: .leading)
                    }
                }
            }
        }
        .frame(height: 32)
    }
}
