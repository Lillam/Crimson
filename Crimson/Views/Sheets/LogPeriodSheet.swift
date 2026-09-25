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
    var existing: Cycle? = nil
    
    /// A fresh draft starting on `date`, with the end guessed from the
    /// user's average bleed length so they usually only need to confirm.
    static func new(startingOn date: Date, stats: CycleStats) -> PeriodDraft {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let length = max(stats.averageBleedLength, 1)
        let end = calendar.date(byAdding: .day, value: length - 1, to: start) ?? start
        return PeriodDraft(start: start, end: end)
    }
    
    static func edit(_ record: Cycle) -> PeriodDraft {
        PeriodDraft(start: record.start, end: record.end, existing: record)
    }
}

/// The single place a period gets saved from. Reached from the calendar (after
/// picking a range), the day view (from the Log/Edit button), or anywhere else
/// that wants to create or edit a record.
struct LogPeriodSheet: View {
    @Environment(CycleStore.self) var store
    @Environment(\.dismiss) private var dismiss
    
    private let existing: Cycle?
    @State private var problem: Problem?
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
        
        do {
            let outcome: LogOutcome
            
            if let existing {
                outcome = try store.update(existing, start: start, end: endDate)
            } else {
                outcome = try store.logPeriod(from: start, to: endDate)
            }
            
            switch outcome {
            case .logged:
                dismiss()
            case .clashes(let period):
                // Left on screen rather than dismissed, so the dates they
                // picked are still there to adjust.
                problem = .clashes(period)
            }
        } catch {
            problem = .saveFailed
        }
    }
    
    private func delete() {
        guard let existing else {
            dismiss()
            return
        }
        
        do {
            try store.delete(existing)
            dismiss()
        } catch {
            problem = .saveFailed
        }
    }
    
    /// Something worth interrupting the user for. Not an `Error`: a clash
    /// carries the `Cycle` it ran into, and `@Model` types aren't `Sendable`.
    private enum Problem {
        case clashes(Cycle)
        case saveFailed
    }
    
    private var problemTitle: String {
        switch problem {
        case .clashes:    "Already logged"
        case .saveFailed: "Couldn't save"
        case nil:         ""
        }
    }
    
    private var problemMessage: String {
        switch problem {
        case .clashes(let period):
            let from = period.start.formatted(.dateTime.day().month(.abbreviated))
            let to = period.end?.formatted(.dateTime.day().month(.abbreviated))
            let range = to.map { "\(from) – \($0)" } ?? "\(from) onwards"
            return "There's already a period logged for \(range). Change these dates, or edit that period instead."
        case .saveFailed:
            return "Your period couldn't be saved. Please try again."
        case nil:
            return ""
        }
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
        .alert(
            problemTitle,
            isPresented: Binding(
                get: { problem != nil },
                set: { if !$0 { problem = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(problemMessage)
        }
    }
}

#Preview("New", traits: .sampleData) {
    LogPeriodSheet(
        draft: .new(
            startingOn: Date(),
            stats: CycleStats(averageCycleLength: 28, averageBleedLength: 4, lastPeriod: nil)
        )
    )
}

// Built from a record rather than pulled out of the store, so the preview
// doesn't depend on what order the sample data came back in.
#Preview("Edit", traits: .sampleData) {
    LogPeriodSheet(
        draft: .edit(
            Cycle(start: toDate("2026-09-04"), end: toDate("2026-09-07"))
        )
    )
}
