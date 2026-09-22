//
//  SettingsView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(ProfileStore.self) var profile
    @Environment(SettingsStore.self) var settings
    @State private var confirmingDelete = false
    @State private var showingDonate = false
    @State private var editingProfile = false
    
    /// The "no limit" switch, written straight back to the store.
    private var isCalendarUnbounded: Binding<Bool> {
        Binding(
            get: { settings.calendarRange.isUnbounded },
            set: { settings.setCalendarUnbounded($0) }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)                
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Text("Editing opens the welcome screen again, right here.")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        row("Name", value: profile.displayName ?? "Not set")
                        Divider().overlay(.black.opacity(0.3))
                        row("Birthday", value: profile.birthday?.formatted ?? "Not set")
                        Divider().overlay(.black.opacity(0.3))
                        
                        // Re-running the welcome is how the profile gets edited, so
                        // there's one place that knows how to collect it. It comes
                        // up as a sheet from here, the same as the donate page —
                        // the app-level presentation is only for the first run.
                        Button(action: { editingProfile = true }) {
                            HStack {
                                Text("Edit profile")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 15)
                        }
                        
                        Divider().overlay(.black.opacity(0.3))
                        
                        Button(action: { confirmingDelete = true }) {
                            HStack {
                                Text("Delete profile")
                                Spacer()
                                Image(systemName: "trash")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 15)
                        }
                        .padding(.top, 10)
                        .confirmationDialog(
                            "Delete your profile?",
                            isPresented: $confirmingDelete,
                            titleVisibility: .visible
                        ) {
                            Button("Delete profile", role: .destructive, action: profile.deleteProfile)
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Your name and birthday will be removed, and you'll be taken through the welcome screen again the next time you open the app. Your logged periods are not affected.")
                        }
                    }
                    .background(.black.opacity(0.05))
                    .cornerRadius(12)
                    
                    Text("Calendar")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    Text("How far the calendar scrolls either side of this month. A smaller window is less to draw and less to scroll through.")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading) {
                            Toggle(isOn: isCalendarUnbounded) {
                                Text("No limit")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .tint(.green)
                            if settings.calendarRange.isUnbounded {
                                Text("The calendar will allow perpetual scrolling, turning this mode on might result in some perforamnce loss as all your data will be loaded from the dawn of time.")
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.7))
                                .padding(.top, 10)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 15)
                        
                        // Only the bounded calendar has a size to set, so the stepper
                        // comes and goes with the switch above it.
                        if case .years(let years) = settings.calendarRange {
                            Divider().overlay(.black.opacity(0.3))
                            yearsRow(years)
                        }
                    }
                    .background(.black.opacity(0.05))
                    .cornerRadius(12)
                    .animation(.snappy(duration: 0.2), value: settings.calendarRange)
                    
                    Text("Support")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    Text("Crimson is free and always will be. If you'd like to chip in, here's where.")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: { showingDonate = true }) {
                            HStack {
                                Text("Feeling generous?")
                                Spacer()
                                Image(systemName: "heart")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 15)
                        }
                    }
                    .background(.black.opacity(0.05))
                    .cornerRadius(12)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 70)
        .background(.white)
        .sheet(isPresented: $editingProfile) {
            WelcomeSheetView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingDonate) {
            FeelingGenerousSheetView()
                .presentationDragIndicator(.visible)
        }
    }
    
    /// How many years either side, with the two ends of the allowed span
    /// disabled rather than hidden so the row never changes width.
    @ViewBuilder
    private func yearsRow(_ years: Int) -> some View {
        let bounds = CalendarRange.yearBounds
        
        HStack {
            VStack(alignment: .leading) {
                Text("Years either way")
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.bottom, 10)
                Text("Increasing this value may cause a drop in performance, increase this value at your own risk.")
                    .font(.system(size: 10))
                    .foregroundColor(.black.opacity(0.8))
            }
            Spacer()
            HStack(spacing: 5) {
                stepButton("minus", enabled: years > bounds.lowerBound, by: -1)
                Text("\(years)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())
                stepButton("plus", enabled: years < bounds.upperBound, by: 1)
            }
        }
        .font(.system(size: 16))
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func stepButton(_ symbol: String, enabled: Bool, by delta: Int) -> some View {
        Button(action: { settings.adjustCalendarYears(by: delta) }) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black.opacity(enabled ? 1 : 0.3))
                .frame(width: 34, height: 34)
                .background(.black.opacity(0.15), in: Circle())
        }
        .disabled(!enabled)
    }
    
    @ViewBuilder
    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.black.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.black)
        }
        .font(.system(size: 16))
        .padding(.vertical, 14)
        .padding(.horizontal, 15)
    }
}

#Preview {
    SettingsView()
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
        .environment(SettingsStore(defaults: UserDefaults(suiteName: "preview")!))
}
