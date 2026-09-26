//
//  CrimsonApp.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI
import SwiftData

@main
struct CrimsonApp: App {
    @State private var router: Router = Router()
    @State private var store: CycleStore
    @State private var profile: ProfileStore
    @State private var settings: SettingsStore = SettingsStore()
    @State private var days: DayLogStore
    
    private let container: ModelContainer

    init() {
        do {
            let container = try ModelContainer(for: CrimsonSchema.schema)
            
            self.container = container
            
            _store = State(initialValue: CycleStore(context: container.mainContext))
            _days = State(initialValue: DayLogStore(context: container.mainContext))
            _profile = State(initialValue: ProfileStore(context: container.mainContext))
        } catch {
            fatalError("Could not open the crimson database \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(router)
                .environment(store)
                .environment(profile)
                .environment(settings)
                // Applied at the root so every sheet and alert inherits it.
                // `.system` resolves to nil, which hands the choice back to
                // iOS rather than pinning it to whatever it was at launch.
                .preferredColorScheme(settings.theme.colorScheme)
                .environment(days)
        }
        // The container built in `init`, not a second one: `.modelContainer(for:)`
        // would make its own, leaving the stores writing to one database and
        // `@Query` reading another.
        .modelContainer(container)
    }
}
