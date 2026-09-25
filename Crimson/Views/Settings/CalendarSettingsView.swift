//
//  CalendarSettingsView.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import SwiftUI

struct CalendarSettingsView: View {
    @Environment(SettingsStore.self) var settings
    
    /// The "no limit" switch, written straight back to the store.
    private var isCalendarUnbounded: Binding<Bool> {
        Binding(
            get: { settings.calendarRange.isUnbounded },
            set: { settings.setCalendarUnbounded($0) }
        )
    }
    
    var body: some View {
        Text("Calendar")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(AppColor.ink)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text("How far the calendar scrolls either side of this month. A smaller window is less to draw and less to scroll through.")
            .font(.system(size: 12))
            .foregroundColor(AppColor.ink.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
        CardView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Toggle(isOn: isCalendarUnbounded) {
                        Text("No limit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColor.ink)
                    }
                    .tint(.green)
                    if settings.calendarRange.isUnbounded {
                        Text("The calendar will allow perpetual scrolling, turning this mode on might result in some perforamnce loss as all your data will be loaded from the dawn of time.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.ink.opacity(0.7))
                        .padding(.top, 10)
                    }
                }
                
                // Only the bounded calendar has a size to set, so the stepper
                // comes and goes with the switch above it.
                if case .years(let years) = settings.calendarRange {
                    Divider().overlay(AppColor.ink.opacity(0.3))
                    let bounds = CalendarRange.yearBounds
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Years either way")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColor.ink)
                            Text("Increasing this value may cause a drop in performance, increase this value at your own risk.")
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.ink.opacity(0.8))
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button(action: { settings.adjustCalendarYears(by: -1) }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColor.ink.opacity((years > bounds.lowerBound) ? 1 : 0.3))
                                    .frame(width: 34, height: 34)
                                    .background(AppColor.ink.opacity(0.15), in: Circle())
                            }
                            .disabled(!(years > bounds.lowerBound))
                            
                            Text("\(years)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColor.ink)
                                .frame(minWidth: 28)
                                .contentTransition(.numericText())
                            
                            Button(action: { settings.adjustCalendarYears(by: 1) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColor.ink.opacity(years < bounds.upperBound ? 1 : 0.3))
                                    .frame(width: 34, height: 34)
                                    .background(AppColor.ink.opacity(0.15), in: Circle())
                            }
                            .disabled(!(years < bounds.upperBound))
                        }
                    }
                    .font(.system(size: 16))
                }
            }
            .animation(.snappy(duration: 0.2), value: settings.calendarRange)
        }
    }
    
    @ViewBuilder
    private func stepButton(_ symbol: String, enabled: Bool, by delta: Int) -> some View {
        Button(action: { settings.adjustCalendarYears(by: delta) }) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColor.ink.opacity(enabled ? 1 : 0.3))
                .frame(width: 34, height: 34)
                .background(AppColor.ink.opacity(0.15), in: Circle())
        }
        .disabled(!enabled)
    }
}

#Preview(traits: .sampleData) {
    VStack(spacing: 20) {
        CalendarSettingsView()
    }
    .padding(20)
}
