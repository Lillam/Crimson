//
//  StatsView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct StatsView: View {
    @Environment(CycleStore.self) var store
    private let engine = CycleEngine()
    private let calendar = Calendar.current
            
    private var nextPeriod: Date? {
        engine.nextPeriodStart(from: store.stats, onOrAfter: Date())
    }
    
    private var cycleVariation: Int? {
        let lengths = store.cycleLengthHistory.map(\.days)
        
        guard let shortest = lengths.min(),
              let longest = lengths.max(), lengths.count >= 2
        else {
            return nil
        }
        
        return Int((Double(longest - shortest) / 2).rounded(.up))
    }
    
    let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            StatTileView(label: "Average Cycle", value: "\(store.stats.averageCycleLength)", unit: "days")
            StatTileView(label: "Average Period", value: "\(store.stats.averageBleedLength)", unit: "days")
            if let nextPeriod {
                let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: nextPeriod).day ?? 0
                StatTileView(
                    label: "Next Period",
                    value: nextPeriod.formatted(.dateTime.day().month(.abbreviated)),
                    unit: days == 0 ? "today" : "in \(days) \(days == 1 ? "day" : "days")"
                )
            }
            
            if let cycleVariation {
                StatTileView(
                    label: "Variation",
                    value: "±\(cycleVariation)",
                    unit: cycleVariation <= 3 ? "days · regular" : "days · varies"
                )
            } else {
                StatTileView(label: "Cycles Logged", value: "\(store.cycleLengthHistory.count)", unit: "so far")
            }
        }
    }
}
