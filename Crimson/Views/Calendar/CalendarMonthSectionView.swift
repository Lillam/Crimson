//
//  CalendarMonthSectionView.swift
//  Crimson
//
//  Created by Liam Taylor on 19/09/2026.
//

import SwiftUI

struct CalendarMonthSectionView: View {
    /// The first of the month to render.
    let month: Date
    /// How a given day should be drawn.
    let marking: (Date) -> DayMarking
    /// Whether a given day can be tapped. Defaults to all of them.
    var isEnabled: (Date) -> Bool = { _ in true }
    let onTap: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        let days = daysIn(in: month)
        let dates = days + Array(repeating: nil, count: max(31 - days.count, 0))
        
        VStack {
            Text(month.formatted(.dateTime.month(.wide)))
                .foregroundColor(.black)
                .padding(.bottom, 10)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(weekShort.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.black.opacity(0.75))
                }
                
                // Day cells
                ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                    if let date {
                        CalendarDaySectionView(
                            date: date,
                            marking: marking(date),
                            isEnabled: isEnabled(date)
                        ) {
                            onTap(date)
                        }
                    } else {
                        // empty leading/trailing cell
                        Color.clear.frame(height: 34)
                    }
                }
            }
        }
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    CalendarMonthSectionView(
        month: Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date(),
        marking: { Calendar.current.isDateInToday($0) ? .period : .none },
        onTap: { _ in }
    )
}
