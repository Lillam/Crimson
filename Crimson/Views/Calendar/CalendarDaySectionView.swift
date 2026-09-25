//
//  CalendarDaySectionView.swift
//  Crimson
//
//  Created by Liam Taylor on 19/09/2026.
//

import SwiftUI

enum DayMarking {
    case selected(RangeEdge) // part of the range the user is picking to log
    case period              // actual logged bleeding day
    case predicted           // inside the predicted next-period window
    case none
    
    /// Where a day sits inside a selected range, so the band can round its
    /// outer corners and the end days can get the strong treatment.
    enum RangeEdge {
        case single, start, middle, end
    }
}

/// A single day cell in the calendar grid.
struct CalendarDaySectionView: View {
    @Environment(DayLogStore.self) var days
    
    let date: Date
    let marking: DayMarking
    /// Whether this day can be tapped right now. Days outside the range the
    /// calendar is currently asking for are dimmed and inert rather than
    /// hidden, so the grid keeps its shape.
    var isEnabled: Bool = true
    let onTap: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isFilled: Bool {
        switch marking {
        case .period,
             .selected(.single),
             .selected(.start),
             .selected(.end): true
        default: false
        }
    }
    
    private var isMiddleSelectedPeriod: Bool {
        switch marking {
        case .selected(.middle): true
        default: false
        }
    }
    
    var body: some View {
        Text(date, format: .dateTime.day())
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: .infinity, minHeight: 34)
            .foregroundColor(isFilled ? .white : isMiddleSelectedPeriod ? .red : AppColor.ink)
            .background {
                switch marking {
                case .selected(let edge):
                    // a translucent band runs through the whole range, with
                    // the two end days filled like a logged day.
                    selectionBand(edge)
                    if edge != .middle {
                        Circle().fill(.red)
                    }
                case .period:
                    // logged period days get the strong filled treatment
                    Circle().fill(.red)
                case .predicted:
                    // projected days are outlined with a dotted ring, not filled
                    Circle().strokeBorder(
                        AppColor.ink.opacity(0.9),
                        style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
                    )
                case .none:
                    if isToday {
                        Circle().strokeBorder(AppColor.ink, lineWidth: 1.5)
                    }
                }
            }
            // A small dot marks days with a mood/symptom/notes entry.
            .overlay(alignment: .bottom) {
                if days.hasEntry(on: date) {
                    Circle()
                        .fill(isFilled ? .white : .red)
                        .frame(width: 4, height: 4)
                        .offset(y: -3)
                }
            }
            .opacity(isEnabled ? 1 : 0.3)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .allowsHitTesting(isEnabled)
            .animation(.snappy(duration: 0.2), value: isEnabled)
    }
    
    /// The band behind a selected range. It reaches half a column gap either
    /// side so neighbouring cells join up, and stops at the middle of the
    /// start/end cells so the range visibly begins and ends on their circles.
    @ViewBuilder
    private func selectionBand(_ edge: DayMarking.RangeEdge) -> some View {
        HStack(spacing: 0) {
            Color.red.opacity(edge == .start || edge == .single ? 0 : 0.3)
            Color.red.opacity(edge == .end || edge == .single ? 0 : 0.3)
        }
        // half the grid's column spacing
        .padding(.horizontal, -5)
    }
}

#Preview(traits: .sampleData) {
    HStack {
        CalendarDaySectionView(date: Date(), marking: .none) {}
        CalendarDaySectionView(date: Date(), marking: .period) {}
        CalendarDaySectionView(date: Date(), marking: .predicted) {}
        CalendarDaySectionView(date: Date(), marking: .selected(.start)) {}
        CalendarDaySectionView(date: Date(), marking: .selected(.middle)) {}
        CalendarDaySectionView(date: Date(), marking: .selected(.end)) {}
        CalendarDaySectionView(date: Date(), marking: .none, isEnabled: false) {}
    }
    .padding()
}
