//
//  RecentPeriodList.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct RecentPeriodList: View {
    @Environment(CycleStore.self) var store
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Recent periods")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.bottom, 8)
                
                ForEach(Array(store.recentRecords.prefix(6).enumerated()), id: \.element.id) { index, record in
                    if index > 0 {
                        Divider().overlay(.black.opacity(0.25))
                    }
                    HStack {
                        Text(record.start.formatted(.dateTime.day().month(.abbreviated).year()))
                            .foregroundColor(.black)
                        Spacer()
                        Text(summary(for: record))
                            .foregroundColor(.black.opacity(0.75))
                    }
                    .font(.system(size: 14))
                    .padding(.vertical, 10)
                }
            }
        }
    }

    /// "Ongoing" while the period is still running, otherwise how long it
    /// lasted. Pulled out of `body` because the ternary-inside-interpolation
    /// version took the type-checker 13 seconds on its own.
    private func summary(for cycle: Cycle) -> LocalizedStringKey {
        guard let length = cycle.length else {
            return "Ongoing"
        }

        return length == 1 ? "\(length) day" : "\(length) days"
    }
}
