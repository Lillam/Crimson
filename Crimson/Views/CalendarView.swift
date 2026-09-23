//
//  CalendarView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct CalendarView: View {
    @Environment(Router.self) var router
    @Environment(CycleStore.self) var store
    @Environment(ProfileStore.self) var profile
    @Environment(SettingsStore.self) var settings
    
    /// How many months past the current one have been loaded. Only ever grows,
    /// and only as the user scrolls down — the calendar never prepends, because
    /// inserting content above the visible month shifts everything on screen.
    /// What's actually shown is `futureMonths`, which clamps this to the range.
    @State private var loadedFutureMonths: Int
    /// The topmost month that's at least half on screen. Observed from the
    /// scroll view (never written back to it), and drives the header.
    @State private var visibleMonth: Date?
    /// Whether the scroll view has been positioned on the current month yet.
    /// The lazy stack can't be scrolled accurately until it has measured a
    /// row, so landing waits for the first layout and the months stay hidden
    /// until then — otherwise there'd be a flash of the oldest month.
    @State private var hasLanded = false
    /// Range-selection mode, entered from the "Log period" button. While on,
    /// taps pick a start and end day instead of navigating to the day view.
    @State private var isSelecting = false
    @State private var selectionStart: Date?
    @State private var selectionEnd: Date?
    /// The period awaiting confirmation in the sheet.
    @State private var draft: PeriodDraft?
    
    private let calendar = Calendar.current
    private let engine: CycleEngine = CycleEngine()
    
    /// How many months ahead to load initially, and how many to add each time
    /// the user nears the bottom.
    private let monthBatch = 12
    /// Load more once the visible month is within this many months of the end,
    /// so the new content is in place before the user reaches it.
    private let edgeBuffer = 3
    /// How far back an unbounded calendar reaches. Something has to anchor the
    /// top of the list, and a lazy stack only builds the months on screen, so
    /// the extra range costs nothing until it's scrolled to.
    private let unboundedHistoryYears = 20
    
    /// The first of the current month.
    private let thisMonth: Date
    
    init() {
        let calendar = Calendar.current
        let thisMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        
        self.thisMonth = thisMonth
        _loadedFutureMonths = State(initialValue: monthBatch)
        _visibleMonth = State(initialValue: thisMonth)
    }
    
    /// Months either side of the current one that the user's range allows, or
    /// nil when they've asked for no limit.
    private var windowMonths: Int? {
        settings.calendarRange.months
    }
    
    /// How many months of history the scroller holds. Fixed while the calendar
    /// is on screen: the start of the list must never move, because inserting
    /// months above the visible one makes the lazy stack lose its place (it
    /// resets to the top). Changing the range in settings rebuilds the list and
    /// re-lands it on the current month.
    private var historyMonths: Int {
        windowMonths ?? unboundedHistoryYears * 12
    }
    
    /// How many months ahead are shown: what's been loaded, capped by the range.
    private var futureMonths: Int {
        min(loadedFutureMonths, windowMonths ?? .max)
    }
    
    /// The oldest month in the scroller.
    private var firstMonth: Date {
        calendar.date(byAdding: .month, value: -historyMonths, to: thisMonth) ?? thisMonth
    }
    
    /// Every month currently in the scroller, oldest → newest, each normalised
    /// to the first of the month.
    private var months: [Date] {
        let count = historyMonths + futureMonths + 1
        return (0..<count).compactMap {
            calendar.date(byAdding: .month, value: $0, to: firstMonth)
        }
    }

    /// Actual logged bleeding days, normalised to the start of each day.
    private var loggedDays: Set<Date> {
        var days: Set<Date> = []
        for record in store.records {
            let last = calendar.startOfDay(for: record.effectiveEndDate)
            var day = calendar.startOfDay(for: record.startDate)
            while day <= last {
                days.insert(day)
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
        }
        return days
    }

    /// Projected future bleeding days, out to the end of the last loaded month.
    private var projectedDays: Set<Date> {
        guard let horizon = calendar.dateInterval(of: .month, for: months.last ?? Date())?.end else {
            return []
        }
        
        let dates = engine.createProjection(from: store.stats, for: horizon)
        
        return Set(dates.map { calendar.startOfDay(for: $0) })
    }

    private func marking(for date: Date, logged: Set<Date>, projected: Set<Date>) -> DayMarking {
        let day = calendar.startOfDay(for: date)
        
        if let edge = selectionEdge(for: day) {
            return .selected(edge)
        }
        
        if logged.contains(day) {
            return .period
        }
        
        if projected.contains(day) {
            return .predicted
        }
        
        return .none
    }
    
    /// Where `day` falls in the range being selected, or nil if it's outside.
    /// Before the second tap only the start day is highlighted.
    private func selectionEdge(for day: Date) -> DayMarking.RangeEdge? {
        guard let start = selectionStart else {
            return nil
        }
        
        let end = selectionEnd ?? start
        
        guard day >= start, day <= end else {
            return nil
        }
        
        return switch (start == end, day == start, day == end) {
        case (true, _, _): .single
        case (_, true, _): .start
        case (_, _, true): .end
        default:           .middle
        }
    }
    
    // MARK: - Selection
    
    /// this might eventually want to be utilising translated strings instead
    /// of actual plain english hardcoded
    private var selectionHint: String {
        selectionStart == nil ? "Tap the first day of your period" : "Now tap the last day"
    }
    
    /// What the status line says when not selecting: a birthday greeting on
    /// the day itself, otherwise the next projected period.
    private var idleStatus: String {
        if profile.isBirthday(Date()) {
            return "Happy birthday\(profile.displayName.map { ", \($0)" } ?? "")! 🎂"
        }
        
        guard let days = engine.daysUntilNextPeriod(from: store.stats, on: Date()) else {
            return "Log a couple of periods to see a projection"
        }
        
        switch days {
        case 0:  return "Period projected today"
        case 1:  return "Period projected tomorrow"
        default: return "Period projected in \(days) days"
        }
    }
    
    private func beginSelecting() {
        withAnimation(.snappy(duration: 0.25)) {
            isSelecting = true
            selectionStart = nil
            selectionEnd = nil
        }
    }
    
    private func cancelSelecting() {
        withAnimation(.snappy(duration: 0.25)) {
            isSelecting = false
            selectionStart = nil
            selectionEnd = nil
        }
    }
    
    /// Handles a tap while in selection mode: first tap sets the start, second
    /// closes the range (in either order) and hands it to the sheet.
    private func select(_ date: Date) {
        let day = calendar.startOfDay(for: date)
        
        guard let start = selectionStart else {
            selectionStart = day
            return
        }
        
        let range = min(start, day)...max(start, day)
        selectionStart = range.lowerBound
        selectionEnd = range.upperBound
        isSelecting = false
        draft = PeriodDraft(start: range.lowerBound, end: range.upperBound)
    }
    
    private func tapped(_ date: Date) {
        if isSelecting {
            select(date)
        } else {
            router.navigate(to: .day(date.formatted(DateFormat.calendarDay)))
        }
    }
    
    /// Loads another batch of future months once the visible month gets close
    /// to the bottom of what's loaded. A bounded calendar simply stops: the
    /// range is the end of the list, not a pause in the loading.
    private func loadMoreIfNeeded() {
        guard
            let visible = visibleMonth,
            let index = months.firstIndex(of: visible),
            months.count - 1 - index < edgeBuffer
        else {
            return
        }
        
        loadedFutureMonths = min(loadedFutureMonths + monthBatch, windowMonths ?? .max)
    }
    
    /// Rebuilds the scroller around the current month after the range changes.
    /// Both ends of the list have moved, so the lazy stack's idea of where it
    /// is no longer means anything and it has to be put back deliberately.
    private func rangeChanged(proxy: ScrollViewProxy) {
        loadedFutureMonths = monthBatch
        visibleMonth = thisMonth
        proxy.scrollTo(thisMonth, anchor: .top)
    }
    
    /// The three-month span headed by the visible month: the month at the top
    /// of the scroll view plus the two that follow it. As a new month scrolls
    /// into the top slot the whole range shifts along with it.
    private var titleRange: (first: Date, last: Date) {
        let first = visibleMonth ?? Date()
        let last = calendar.date(byAdding: .month, value: 2, to: first) ?? first
        return (first, last)
    }
    
    /// "Jun - Aug"
    private var rangeTitle: String {
        let range = titleRange
        return "\(range.first.formatted(.dateTime.month(.abbreviated))) - \(range.last.formatted(.dateTime.month(.abbreviated)))"
    }
        
    /// "2026", or "2026 - 2027" when the span crosses a year boundary.
    private var yearTitle: String {
        let range = titleRange
        let firstYear = range.first.formatted(.dateTime.year())
        let lastYear = range.last.formatted(.dateTime.year())
        
        if firstYear == lastYear {
            return lastYear
        }
        
        return "\(firstYear) - \(lastYear)"
    }
    
    var body: some View {
        // Computed once per body evaluation rather than per month or per cell.
        let logged = loggedDays
        let projected = projectedDays
        
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(rangeTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .contentTransition(.numericText())
                    Text(yearTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.75))
                        .contentTransition(.numericText())
                }
                .animation(.snappy(duration: 0.2), value: visibleMonth)
                
                Spacer()
                
                // The same button swaps between the two modes in place, so the
                // header never changes height.
                Button(action: isSelecting ? cancelSelecting : beginSelecting) {
                    Label(isSelecting ? "Cancel" : "Log period", systemImage: isSelecting ? "xmark" : "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelecting ? .red : .white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(isSelecting ? .red.opacity(0.25) : .red)
                        .cornerRadius(20)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .padding([.top, .horizontal], 20)
            .padding(.bottom, 10)
            
            // A permanent one-line status slot. Swapping its text rather than
            // inserting a banner keeps the scroll view's frame fixed — a scroll
            // view that resizes mid-scroll loses its place.
            Text(isSelecting ? selectionHint : idleStatus)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(.red)
                .contentTransition(.opacity)
                .animation(.snappy(duration: 0.2), value: selectionStart)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(months, id: \.self) { month in
                            CalendarMonthSectionView(
                                month: month,
                                marking: {
                                    marking(for: $0, logged: logged, projected: projected)
                                },
                                onTap: tapped
                            )
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.bottom, 80) // scroll clear of the floating tab bar
                }
                // Land on the current month once the stack has laid out (its
                // content size is known). Every month is the same height, so
                // from that point the target's offset is exact. Doing this on
                // appear instead runs before layout and lands anywhere.
                .onScrollGeometryChange(for: Bool.self, of: { $0.contentSize.height > 0 }) { _, hasContent in
                    guard hasContent, !hasLanded else {
                        return
                    }
                    
                    // Deferred: scrolling and flipping `hasLanded` inside the
                    // geometry callback would change the geometry again in
                    // the same frame, which SwiftUI flags.
                    DispatchQueue.main.async {
                        guard !hasLanded else {
                            return
                        }
                        
                        proxy.scrollTo(thisMonth, anchor: .top)
                        hasLanded = true
                    }
                }
                .opacity(hasLanded ? 1 : 0)
                .onScrollTargetVisibilityChange(idType: Date.self, threshold: 0.5) { visible in
                    if let top = visible.min(), top != visibleMonth {
                        visibleMonth = top
                    }
                }
                .scrollIndicators(.hidden)
                .onChange(of: visibleMonth, loadMoreIfNeeded)
                .onChange(of: settings.calendarRange) {
                    rangeChanged(proxy: proxy)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // Top padding only, so the month list runs under the tab bar.
        // Keep the range banded on the calendar while the sheet is up so the
        // user can see what they're confirming; clear it once it goes away.
        .sheet(item: $draft, onDismiss: cancelSelecting) { draft in
            LogPeriodSheet(draft: draft)
        }
    }
}

#Preview {
    CalendarView()
        .environment(Router())
        .environment(CycleStore())
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
        .environment(SettingsStore(defaults: UserDefaults(suiteName: "preview")!))
        .environment(DayEntryStore(fileURL: nil))
}
