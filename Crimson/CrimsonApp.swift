//
//  CrimsonApp.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

@main
struct CrimsonApp: App {
    @State private var router: Router = Router()
    @State private var store: CycleStore = CycleStore()
    @State private var profile: ProfileStore = ProfileStore()
    @State private var entries: DayEntryStore = DayEntryStore()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(router)
                .environment(store)
                .environment(profile)
                .environment(entries)
        }
    }
}
