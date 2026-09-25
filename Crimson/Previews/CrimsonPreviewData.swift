//
//  CrimsonPreviewData.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import SwiftUI
import SwiftData

/// Everything a preview needs, in one trait: an in-memory database with some
/// sample rows in it, and the stores that read from it.
///
/// `makeSharedContext()` runs once per preview process, so the container is
/// built and seeded a single time however many previews use it. Use it as
/// `#Preview(traits: .sampleData) { … }`.
struct CrimsonPreviewData: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: CrimsonSchema.schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        seed(container.mainContext)

        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
            .environment(Router())
            .environment(CycleStore(context: context.mainContext))
            .environment(DayLogStore(context: context.mainContext))
            .environment(ProfileStore(defaults: .preview))
            .environment(SettingsStore(defaults: .preview))
    }

    /// A few months of plausible history, so the calendar and the charts have
    /// something to draw rather than an empty state.
    private static func seed(_ context: ModelContext) {
        context.insert(User(name: "Liam", birthday: User.Birthday(day: 14, month: 3)))

        let periods = [
            ("2026-05-11", "2026-05-15"),
            ("2026-06-10", "2026-06-13"),
            ("2026-07-09", "2026-07-12"),
            ("2026-08-05", "2026-08-08"),
            ("2026-09-04", "2026-09-07"),
        ]

        for (start, end) in periods {
            context.insert(Cycle(start: toDate(start), end: toDate(end)))
        }

        context.insert(
            DayLog(
                date: toDate("2026-09-04"),
                mood: .low,
                energy: .drained,
                flow: .heavy,
                symptoms: [.cramps, .fatigue]
            )
        )

        context.insert(
            DayLog(
                date: toDate("2026-09-05"),
                mood: .okay,
                energy: .steady,
                flow: .medium,
                symptoms: [.bloating],
                notes: "Felt better after a walk."
            )
        )

        try? context.save()
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    /// An in-memory database with sample data, plus every store the app
    /// injects at launch.
    static var sampleData: Self { .modifier(CrimsonPreviewData()) }
}

extension UserDefaults {
    /// A throwaway defaults suite, so previews never read or write the ones
    /// the app itself uses.
    static let preview = UserDefaults(suiteName: "preview")!
}
