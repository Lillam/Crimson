//
//  LogPeriodSheet.swift
//  Crimson
//
//  Created by Liam Taylor on 16/09/2026.
//

import SwiftUI

/// What a user is about to log: a proposed date range, and the record it
/// replaces if they're editing rather than creating. Presented via
/// `.sheet(item:)`, hence `Identifiable`.
struct PeriodDraft: Identifiable {
    let id = UUID()
    var start: Date
    var end: Date?
    var existing: CycleRecord? = nil
    
    /// A fresh draft starting on `date`, with the end guessed from the
    /// user's average bleed length so they usually only need to confirm.
    static func new(startingOn date: Date, stats: CycleStats) -> PeriodDraft {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let length = max(stats.averageBleedLength, 1)
        let end = calendar.date(byAdding: .day, value: length - 1, to: start) ?? start
        return PeriodDraft(start: start, end: end)
    }
    
    static func edit(_ record: CycleRecord) -> PeriodDraft {
        PeriodDraft(start: record.startDate, end: record.endDate, existing: record)
    }
}

/// The single place a period gets saved from. Reached from the calendar (after
/// picking a range), the day view (from the Log/Edit button), or anywhere else
/// that wants to create or edit a record.
struct LogPeriodSheet: View {
    @Environment(CycleStore.self) var store
    @Environment(\.dismiss) private var dismiss
    
    private let existing: CycleRecord?
    @State private var start: Date
    @State private var end: Date
    @State private var isOngoing: Bool
    
    private let calendar = Calendar.current
    
    init(draft: PeriodDraft) {
        existing = draft.existing
        _start = State(initialValue: draft.start)
        _end = State(initialValue: draft.end ?? draft.start)
        _isOngoing = State(initialValue: draft.end == nil)
    }
    
    private var isEditing: Bool {
        existing != nil
    }
    
    /// A period can only be "ongoing" if it started on or before today.
    private var canBeOngoing: Bool {
        calendar.startOfDay(for: start) <= calendar.startOfDay(for: Date())
    }
    
    private var summary: String {
        let lastDay = isOngoing ? max(Date(), start) : end
        let days = (calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: lastDay)).day ?? 0) + 1
        let range = "\(start.formatted(.dateTime.day().month(.abbreviated))) – \(isOngoing ? "now" : lastDay.formatted(.dateTime.day().month(.abbreviated)))"
        return "\(range)  ·  \(days) \(days == 1 ? "day" : "days")"
    }
    
    private func save() {
        let endDate: Date? = isOngoing ? nil : end
        
        if let existing {
            store.update(existing, start: start, end: endDate)
        } else {
            store.logPeriod(from: start, to: endDate)
        }
        
        dismiss()
    }
    
    private func delete() {
        if let existing {
            store.delete(existing)
        }
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Start", selection: $start, displayedComponents: .date)
                        .onChange(of: start) {
                            // Keep the range valid if the start is dragged past the end.
                            if end < start { end = start }
                            if !canBeOngoing { isOngoing = false }
                        }
                    
                    if !isOngoing {
                        DatePicker("End", selection: $end, in: start..., displayedComponents: .date)
                    }
                    
                    if canBeOngoing {
                        Toggle("Ongoing", isOn: $isOngoing)
                    }
                } footer: {
                    Text(summary)
                }
                
                if isEditing {
                    Section {
                        Button("Delete period", role: .destructive, action: delete)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit period" : "Log period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                }
            }
        }
//        .tint(.red)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        // Solid backdrop instead of the default translucent material.
        .presentationBackground(Color(.systemGroupedBackground))
    }
}

#Preview("New") {
    LogPeriodSheet(draft: .new(startingOn: Date(), stats: CycleStore().stats))
        .environment(CycleStore())
}

#Preview("Edit") {
    let store = CycleStore()
    LogPeriodSheet(draft: .edit(store.records[0]))
        .environment(store)
}
