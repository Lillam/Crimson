//
//  DayView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct DayView: View {
    @Environment(CycleStore.self) var store
    @Environment(DayEntryStore.self) var entries
    
    @State var selected: Date = Date()
    @State private var draft: PeriodDraft?
    /// The notes editor's focus. Held here rather than in `DayLogView` so a
    /// tap anywhere on the page — header included — can dismiss the keyboard.
    @FocusState private var notesFocused: Bool
    private let calendar = Calendar.current
    private let engine = CycleEngine()
    
    /// How far a swipe has to travel before it counts as a page turn.
    private let swipeThreshold: CGFloat = 50
    
    private var weekStart: Date? {
        calendar.dateInterval(of: .weekOfYear, for: selected)?.start
    }
    
    private var week: [Date] {
        guard let start = weekStart else {
            return []
        }
        
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
    
    /// Moves the selected day by `days` (negative for backwards).
    private func navigate(by days: Int) {
        if let target = calendar.date(byAdding: .day, value: days, to: selected) {
            selected = target
        }
    }
    
    /// Swiping left reveals the next day, swiping right the previous — the
    /// platform convention. Fires once the finger lifts, and only for a
    /// clearly horizontal swipe so a future vertical scroll won't trigger it.
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                // A quick flick may not travel far, so also honour the
                // projected end point.
                let projected = value.predictedEndTranslation.width
                let distance = abs(dx) > abs(projected) ? dx : projected
                
                guard abs(distance) > swipeThreshold, abs(dx) > abs(dy) else {
                    return
                }
                
                navigate(by: distance < 0 ? 1 : -1)
            }
    }
    
    /// The logged period the selected day falls inside, if any.
    private var currentRecord: CycleRecord? {
        store.record(containing: selected)
    }
    
    private var isFuture: Bool {
        calendar.startOfDay(for: selected) > calendar.startOfDay(for: Date())
    }
    
    /// Where the day sits in its cycle, for the phase line.
    private var position: CyclePosition? {
        engine.position(on: selected, from: store.stats)
    }
    
    /// An open period the selected day could close: it has to have started on
    /// or before the selected day.
    private var endableRecord: CycleRecord? {
        guard
            let open = store.openRecord,
            calendar.startOfDay(for: selected) >= calendar.startOfDay(for: open.startDate)
        else {
            return nil
        }
        
        return open
    }
    
    /// The headline stat for the selected day: which day of a period it is if
    /// one's logged, otherwise how far away the next projected one is. Both
    /// are recomputed from the store every time the view loads.
    private var headline: (label: String, value: String) {
        if let record = currentRecord {
            let day = (calendar.dateComponents([.day], from: calendar.startOfDay(for: record.startDate), to: calendar.startOfDay(for: selected)).day ?? 0) + 1
            return ("Period Day", "Day \(day)")
        }
        
        guard let days = engine.daysUntilNextPeriod(from: store.stats, on: selected) else {
            return ("Period In", "Unknown")
        }
        
        switch days {
        case 0:  return ("Period Started", "Today")
        case 1:  return ("Period Starts in", "1 Day")
        default: return ("Period Starts in", "\(days) Days")
        }
    }
    
    /// What the main button does depends on the selected day: close an open
    /// period, edit the one it's in, or log a new one starting there.
    private var action: (title: String, perform: () -> Void) {
        if let _ = endableRecord {
            return ("Period Ended", { store.endPeriod(on: selected) })
        } else if let record = currentRecord {
            return ("Edit Period", { draft = .edit(record) })
        } else {
            return ("Log Period", { draft = .new(startingOn: selected, stats: store.stats) })
        }
    }
    
    private var ordinalDay: String {
        let day = calendar.component(.day, from: selected)
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Button(action: { navigate(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(.red)
                            .cornerRadius(10)
                    }
                    Spacer()
                    VStack {
                        Text("\(selected.formatted(.dateTime.weekday(.wide))) \(ordinalDay)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text(selected, format: .dateTime.month(.wide).year())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    Spacer()
                    Button(action: { navigate(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(.red)
                            .cornerRadius(10)
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { date in
                        let isSelected = calendar.isDate(selected, inSameDayAs: date)
                        let isToday = calendar.isDateInToday(date)
                        
                        VStack(spacing: 10) {
                            Text(date, format: .dateTime.weekday(.narrow))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            
                            Text(date, format: .dateTime.day())
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 34, height: 34)
                                .background(isToday ? Color.white : .clear, in: Circle())
                                .overlay(
                                    (isSelected)
                                    ? Circle().stroke(isToday ? .red : .white, style: StrokeStyle(lineWidth: 2, dash: [2, 4]))
                                    : nil
                                )
                                .foregroundStyle(isToday ? .red : .white)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { selected = date }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(.red)
            // The day's log, on the white body under the red header.
            ScrollView {
                VStack {
                    Text(headline.label)
                        .foregroundColor(.black.opacity(0.8))
                    Text(headline.value)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                    Button(action: action.perform) {
                        Text(action.title)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(.red)
                    .cornerRadius(20)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .padding(.top, 30)
                VStack(spacing: 12) {
                    if let position {
                        phaseCard(position)
                    }
                    
                    if isFuture {
                        futureNote
                    } else {
                        DayLogView(date: selected, isPeriodDay: currentRecord != nil, notesFocused: $notesFocused)
                    }
                }
                .padding(20)
                .padding(.bottom, 80) // scroll clear of the floating tab bar
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Fill the screen (like the calendar) so the swipe hit area is the
        // whole page, not just the header.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.white)
        // Make the whole page swipeable. Simultaneous so the vertical scroll
        // underneath still works; the gesture only acts on clearly
        // horizontal swipes.
        .contentShape(Rectangle())
        .simultaneousGesture(swipe)
        // Tapping any blank part of the page drops the keyboard. Controls
        // consume their own taps, so this only fires on empty space (and the
        // scroll view already dismisses on drag).
        .onTapGesture { notesFocused = false }
        .sensoryFeedback(.selection, trigger: selected)
        .sheet(item: $draft) { draft in
            LogPeriodSheet(draft: draft)
        }
    }
    
    /// One line of cycle context for the day: which phase it's in and what
    /// that usually means.
    @ViewBuilder
    private func phaseCard(_ position: CyclePosition) -> some View {
        let isLate = position.daysLate > 0
        
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(isLate ? "Late" : position.phase.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text("· Day \(position.day) of ~\(position.cycleLength)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.75))
            }
            Text(isLate
                 ? "\(position.daysLate) \(position.daysLate == 1 ? "day" : "days") past your usual cycle length."
                 : position.phase.summary)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red)
        .cornerRadius(12)
    }
    
    private var futureNote: some View {
        Text("This day hasn't happened yet — come back to log how it went.")
            .font(.system(size: 13))
            .foregroundColor(.black.opacity(0.75))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background(DayLogView.cardColor)
            .cornerRadius(12)
    }
}

#Preview {
    DayView(selected: Date())
        .environment(CycleStore())
        .environment(DayEntryStore(fileURL: nil))
}
