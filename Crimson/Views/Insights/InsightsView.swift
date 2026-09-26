//
//  InsightsView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @Environment(CycleStore.self) var cycles
    @Environment(ProfileStore.self) var profileStore
    
    /// How far back the day-log cards look. The cycle cards above them are
    /// unaffected — those are built from averages over everything logged.
    @State private var scope: InsightsScope = .twelveMonths
    
    private let calendar = Calendar.current
    private let engine = CycleEngine()
    
    private var pageSubtitle: String {
        guard let profile = profileStore.profile, let displayName = profile.displayName else {
            return "How your cycle's looking"
        }
        
        return "How your cycle's looking \(displayName)"
    }
    
    /// Everything on this page is derived from the store's averages, so
    /// there's nothing to show until there are two periods to average.
    private var hasEnoughData: Bool {
        cycles.stats.averageCycleLength > 0
    }
    
    private var position: CyclePosition? {
        engine.position(on: Date(), from: cycles.stats)
    }
    
    private var nextPeriod: Date? {
        engine.nextPeriodStart(from: cycles.stats, onOrAfter: Date())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageTitle(title: "Insights", subtitle: pageSubtitle)
                VStack(alignment: .leading, spacing: 20) {
                    if !hasEnoughData {
                        CardView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nothing to show yet")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColor.ink)
                                Text("Insights are built from your averages, so they appear once two periods have been logged. Use Log period on the calendar to add them — past ones count too.")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.ink.opacity(0.75))
                            }
                        }
                    } else {
                        CurrentCycleView(position: position)
                        StatsView()
                        HistoryChartBoxView(
                            title: "Cycle length",
                            subtitle: "Days from one period start to the next",
                            samples: cycles.cycleLengthHistory,
                            average: cycles.stats.averageCycleLength
                        )
                        HistoryChartBoxView(
                            title: "Period length",
                            subtitle: "Days of bleeding each period",
                            samples: cycles.bleedLengthHistory,
                            average: cycles.stats.averageBleedLength
                        )
                        RecentPeriodList()
                    }
                    
                    // One control, sitting above everything it governs.
                    HStack {
                        Text("Daily logs")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColor.ink)
                        
                        Spacer()
                        
                        ScopePickerView(scope: $scope)
                    }
                    .padding(.top, 10)
                    
                    LoggingStatView(scope: scope)
                    SymptomFrequencyView(scope: scope)
                    MoodTrendView(scope: scope)
                    MoodByPhaseView(scope: scope)
                }
                .padding(.bottom, 100)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // Top padding only: the scroll view must touch the bottom safe area
        // so it extends under it (and the tab bar) rather than being clipped.
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .background(AppColor.page)
        .ignoresSafeArea()
    }
}

#Preview(traits: .sampleData) {
    InsightsView()
}
