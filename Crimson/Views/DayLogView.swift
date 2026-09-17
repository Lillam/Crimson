//
//  DayLogView.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import SwiftUI

/// The editable part of the day page: how the user felt, what they noticed,
/// and anything they want to write down. Every control writes straight
/// through to the store, so there's no save button.
struct DayLogView: View {
    /// The card grey, shared with the day page's other cards.
    static let cardColor = Color(.white.opacity(0.05))
    
    @Environment(DayEntryStore.self) var entries
    let date: Date
    /// Whether this is a day the user has logged bleeding on — flow is only
    /// asked about then (plus spotting on any day).
    let isPeriodDay: Bool
    
    @FocusState private var notesFocused: Bool
    
    private var entry: DayEntry {
        entries.entry(for: date)
    }
    
    /// A binding into one field of today's entry that persists on set.
    private func field<T>(_ keyPath: WritableKeyPath<DayEntry, T>) -> Binding<T> {
        Binding(
            get: { entries.entry(for: date)[keyPath: keyPath] },
            set: { value in entries.update(for: date) { $0[keyPath: keyPath] = value } }
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            scaleCard("Mood", scale: Scale.mood, selection: field(\.mood))
            scaleCard("Energy", scale: Scale.energy, selection: field(\.energy))
            flowCard
            symptomsCard
            notesCard
        }
    }
    
    // MARK: - Mood / energy
    
    @ViewBuilder
    private func scaleCard(_ title: String, scale: [(emoji: String, label: String)], selection: Binding<Int?>) -> some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle(title, detail: selection.wrappedValue.map { scale[$0 - 1].label })
                
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { value in
                        let isSelected = selection.wrappedValue == value
                        Button {
                            // Tapping the current choice clears it.
                            selection.wrappedValue = isSelected ? nil : value
                        } label: {
                            Text(scale[value - 1].emoji)
                                .font(.system(size: isSelected ? 30 : 24))
                                .frame(width: 44, height: 44)
                                .background(isSelected ? .white : .red.opacity(0.15), in: Circle())
                                .opacity(selection.wrappedValue == nil || isSelected ? 1 : 0.45)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(scale[value - 1].label)
                    }
                }
                .animation(.snappy(duration: 0.2), value: selection.wrappedValue)
            }
        }
    }
    
    // MARK: - Flow
    
    private var flowCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle("Flow", detail: entry.flow?.title)
                
                HStack(spacing: 6) {
                    ForEach(DayEntry.Flow.allCases) { flow in
                        chip(flow.title, isSelected: entry.flow == flow) {
                            entries.update(for: date) { $0.flow = $0.flow == flow ? nil : flow }
                        }
                    }
                }
                
                if !isPeriodDay && entry.flow != nil && entry.flow != .spotting {
                    Text("This day isn't inside a logged period — use Log Period above if it should be.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
        }
    }
    
    // MARK: - Symptoms
    
    private var symptomsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle("Symptoms", detail: entry.symptoms.isEmpty ? nil : "\(entry.symptoms.count)")
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 6)], alignment: .leading, spacing: 6) {
                    ForEach(DayEntry.Symptom.allCases) { symptom in
                        chip(symptom.title, isSelected: entry.symptoms.contains(symptom)) {
                            entries.update(for: date) {
                                if $0.symptoms.contains(symptom) {
                                    $0.symptoms.remove(symptom)
                                } else {
                                    $0.symptoms.insert(symptom)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Notes
    
    private var notesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                cardTitle("Notes", detail: nil)
                
                TextEditor(text: field(\.notes))
                    .focused($notesFocused)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .tint(.red)
                    .font(.system(size: 15))
                    .frame(minHeight: 90)
                    .overlay(alignment: .topLeading) {
                        if entry.notes.isEmpty {
                            Text("How was your day?")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.75))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                
                if notesFocused {
                    HStack {
                        Spacer()
                        Button("Done") { notesFocused = false }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // MARK: - Pieces
    
    @ViewBuilder
    private func cardTitle(_ title: String, detail: String?) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.75))
                    .contentTransition(.numericText())
            }
        }
    }
    
    @ViewBuilder
    private func chip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .red : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? .white : .white.opacity(0.1), in: Capsule())
        }
    }
    
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Self.cardColor)
            .cornerRadius(12)
    }
}

#Preview {
    ScrollView {
        DayLogView(date: Date(), isPeriodDay: true)
            .padding(20)
    }
    .background(.red)
    .environment(DayEntryStore(fileURL: nil))
}
