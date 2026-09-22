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
                        Text(record.startDate.formatted(.dateTime.day().month(.abbreviated).year()))
                            .foregroundColor(.black)
                        Spacer()
                        Text(record.isOngoing
                             ? "Ongoing"
                             : "\(record.bleedLength ?? 0) \(record.bleedLength == 1 ? "day" : "days")")
                        .foregroundColor(.black.opacity(0.75))
                    }
                    .font(.system(size: 14))
                    .padding(.vertical, 10)
                }
            }
        }
    }
}
