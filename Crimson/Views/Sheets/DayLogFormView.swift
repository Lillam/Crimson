//
//  DayLogFormView.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import SwiftUI

/// The editable part of the day page: how the user felt, what they noticed,
/// and anything they want to write down. Every control writes straight
/// through to the store, so there's no save button.
struct DayLogFormView: View {
    /// The card colour, shared with the day page's other cards. White on a
    /// white page, so the cards are drawn with a hairline and a soft shadow
    /// rather than a fill — see `card(_:)`.
    static let cardColor = Color(.white)
    /// Shared by the flow and symptom grids: as many chips per row as fit,
    /// which is two on a phone.
    private static let chipColumns = [GridItem(.adaptive(minimum: 140), spacing: 6)]
    
    @Environment(DayEntryStore.self) var entries
    let date: Date
    /// Whether this is a day the user has logged bleeding on — flow is only
    /// asked about then (plus spotting on any day).
    let isPeriodDay: Bool
    /// Owned by the page so a tap anywhere on it can dismiss the keyboard.
    var notesFocused: FocusState<Bool>.Binding
    
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
            scaleCard("Mood", icon: "face.smiling", scale: Scale.mood, selection: field(\.mood))
            scaleCard("Energy", icon: "bolt.fill", scale: Scale.energy, selection: field(\.energy))
            flowCard
            symptomsCard
            notesCard
        }
        // One tick per change, wherever in the log it came from.
        .sensoryFeedback(.selection, trigger: entry)
    }
    
    // MARK: - Mood / energy
    
    /// Five faces, each with its word underneath, so the row can be read
    /// without tapping anything: 😴 Drained through to ⚡️ Energised.
    @ViewBuilder
    private func scaleCard(_ title: String, icon: String, scale: [(emoji: String, label: String)], selection: Binding<Int?>) -> some View {
        let chosen = selection.wrappedValue
        
        card {
            VStack(alignment: .leading, spacing: 14) {
                cardTitle(
                    title,
                    icon: icon,
                    tint: chosen.map { Scale.tint(step: $0) } ?? .red,
                    detail: chosen.map { scale[$0 - 1].label },
                    detailTint: chosen.map { Scale.tint(step: $0) }
                )
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { value in
                        let step = scale[value - 1]
                        let tint = Scale.tint(step: value)
                        let isSelected = chosen == value
                        // Once something's chosen the rest step back, so the
                        // answer stands out from a glance at the page.
                        let isDimmed = chosen != nil && !isSelected
                        
                        Button {
                            notesFocused.wrappedValue = false
                            // Tapping the current choice clears it.
                            selection.wrappedValue = isSelected ? nil : value
                        } label: {
                            VStack(spacing: 6) {
                                Text(step.emoji)
                                    .font(.system(size: isSelected ? 28 : 22))
                                    .frame(width: 46, height: 46)
                                    .background {
                                        Circle()
                                            .fill(tint.opacity(isSelected ? 1 : 0.16))
                                    }
                                    .overlay {
                                        Circle()
                                            .stroke(tint.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
                                    }
                                    .shadow(color: tint.opacity(isSelected ? 0.35 : 0), radius: 6, y: 3)
                                
                                Text(step.label)
                                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? tint : .black.opacity(0.55))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .opacity(isDimmed ? 0.5 : 1)
                            .scaleEffect(isSelected ? 1.04 : 1)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(step.label)
                    }
                }
                .animation(.snappy(duration: 0.25), value: chosen)
            }
        }
    }
    
    // MARK: - Flow
    
    private var flowCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle(
                    "Flow",
                    icon: "drop.fill",
                    tint: entry.flow?.tint ?? .red,
                    detail: entry.flow?.title,
                    detailTint: entry.flow?.tint
                )
                
                // The same grid as the symptoms below: four across would
                // squeeze the longer words out now the discs take a slice.
                LazyVGrid(columns: Self.chipColumns, alignment: .leading, spacing: 6) {
                    ForEach(DayEntry.Flow.allCases) { flow in
                        chip(flow.title, icon: flow.icon, tint: flow.tint, isSelected: entry.flow == flow) {
                            entries.update(for: date) {
                                $0.flow = $0.flow == flow ? nil : flow
                            }
                        }
                    }
                }
                .animation(.snappy(duration: 0.2), value: entry.flow)
                
                if !isPeriodDay && entry.flow != nil {
                    note("This day isn't inside a logged period — use Log Period above if it should be.")
                }
            }
        }
    }
    
    // MARK: - Symptoms
    
    private var symptomsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle(
                    "Symptoms",
                    icon: "cross.case.fill",
                    tint: .red,
                    detail: entry.symptoms.isEmpty ? nil : "\(entry.symptoms.count)",
                    detailTint: .red
                )
                
                LazyVGrid(columns: Self.chipColumns, alignment: .leading, spacing: 6) {
                    ForEach(DayEntry.Symptom.allCases) { symptom in
                        chip(symptom.title, icon: symptom.icon, tint: symptom.tint, isSelected: entry.symptoms.contains(symptom)) {
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
                .animation(.snappy(duration: 0.2), value: entry.symptoms)
            }
        }
    }
    
    // MARK: - Notes
    
    private var notesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                cardTitle(
                    "Notes",
                    icon: "square.and.pencil",
                    tint: .red,
                    detail: nil,
                    detailTint: nil
                )
                
                TextEditor(text: field(\.notes))
                    .focused(notesFocused)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.black.opacity(0.8))
                    .tint(.red)
                    .font(.system(size: 15))
                    .frame(minHeight: 90)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(notesFocused.wrappedValue ? .red.opacity(0.4) : .black.opacity(0.08), lineWidth: 1)
                    }
                    .overlay(alignment: .topLeading) {
                        if entry.notes.isEmpty {
                            Text("How was your day?")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.4))
                                .padding(.top, 14)
                                .padding(.leading, 15)
                                .allowsHitTesting(false)
                        }
                    }
                    .animation(.snappy(duration: 0.2), value: notesFocused.wrappedValue)
                
                if notesFocused.wrappedValue {
                    HStack {
                        Spacer()
                        Button("Done") { notesFocused.wrappedValue = false }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    // MARK: - Pieces
    
    /// The card's heading: a tinted glyph, the title, and the current answer
    /// as a pill on the right. The glyph picks up the answer's colour, so a
    /// filled-in card is obvious while scrolling past it.
    @ViewBuilder
    private func cardTitle(_ title: String, icon: String, tint: Color, detail: String?, detailTint: Color?) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(tint, in: RoundedRectangle(cornerRadius: 8))
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            if let detail {
                let pillTint = detailTint ?? .red
                
                Text(detail)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(pillTint)
                    .contentTransition(.numericText())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(pillTint.opacity(0.12), in: Capsule())
            }
        }
        .animation(.snappy(duration: 0.2), value: tint)
    }
    
    /// A pickable option: its icon in a white disc, then the word, pale in
    /// its own colour when off and filled with it when on. Left-aligned, so
    /// the discs line up down the column and the words start together.
    @ViewBuilder
    private func chip(_ title: String, icon: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            notesFocused.wrappedValue = false
            action()
        } label: {
            HStack(spacing: 8) {
                // The disc stays white in both states, so the icon keeps its
                // own colour once the chip itself is filled.
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 24, height: 24)
                    .background(.white, in: Circle())
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .black.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 6)
            .padding(.leading, 6)
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(isSelected ? 1 : 0.12), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(tint.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
            }
            .shadow(color: tint.opacity(isSelected ? 0.3 : 0), radius: 5, y: 2)
        }
    }
    
    @ViewBuilder
    private func note(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.red.opacity(0.8))
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.black.opacity(0.7))
        }
    }
    
    /// Cards are white on a white page, so they're separated by a hairline
    /// and a soft shadow rather than a fill.
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Self.cardColor, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.black.opacity(0.07), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

#Preview {
    @Previewable @FocusState var notesFocused: Bool
    
    ScrollView {
        DayLogFormView(date: Date(), isPeriodDay: true, notesFocused: $notesFocused)
            .padding(20)
    }
    .environment(DayEntryStore(fileURL: nil))
}
