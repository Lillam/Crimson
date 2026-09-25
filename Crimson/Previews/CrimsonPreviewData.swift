//
//  CrimsonPreviewData.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import SwiftUI
import SwiftData

/// The stores a preview runs against, built once per preview process.
///
/// They live here rather than being made inside `body` because `body` is
/// re-evaluated on every change: a store created there would be replaced the
/// moment anything wrote to it, so the write would appear to do nothing.
@MainActor
struct CrimsonPreviewWorld {
    let container: ModelContainer
    let router: Router
    let cycles: CycleStore
    let days: DayLogStore
    let profile: ProfileStore
    let settings: SettingsStore
}

/// Everything a preview needs, in one trait: an in-memory database with some
/// sample rows in it, and the stores that read from it.
///
/// `makeSharedContext()` runs once per preview process, so the container is
/// built and seeded a single time however many previews use it. Use it as
/// `#Preview(traits: .sampleData) { … }`.
struct CrimsonPreviewData: PreviewModifier {
    @MainActor
    static func makeSharedContext() async throws -> CrimsonPreviewWorld {
        let container = try ModelContainer(
            for: CrimsonSchema.schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        seed(container.mainContext)

        return CrimsonPreviewWorld(
            container: container,
            router: Router(),
            cycles: CycleStore(context: container.mainContext),
            days: DayLogStore(context: container.mainContext),
            profile: ProfileStore(defaults: .preview),
            settings: SettingsStore(defaults: .preview)
        )
    }

    func body(content: Content, context: CrimsonPreviewWorld) -> some View {
        // Wrapped rather than applying `.preferredColorScheme` here, because
        // this has to *observe* the store to re-render when the theme changes
        // — and only a View's body does that.
        ThemedPreview { content }
            .modelContainer(context.container)
            .environment(context.router)
            .environment(context.cycles)
            .environment(context.days)
            .environment(context.profile)
            .environment(context.settings)
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

/// Applies the theme the same way `CrimsonApp` does, so a preview reacts to
/// the theme picker exactly as the running app would.
private struct ThemedPreview<Content: View>: View {
    @Environment(SettingsStore.self) private var settings

    @ViewBuilder var content: Content

    var body: some View {
        content.preferredColorScheme(settings.theme.colorScheme)
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
