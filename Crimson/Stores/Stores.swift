//
//  StoreManager.swift
//  Crimson
//
//  Created by Liam Taylor on 18/09/2026.
//

import SwiftUI

@Observable
final class Stores {
    let cycles: CycleStore
    let profile: ProfileStore
    let entries: DayEntry
    
    init(
        cycles: CycleStore = CycleStore(),
        profile: ProfileStore = ProfileStore(),
        entries: DayEntry = DayEntry()
    ) {
        self.cycles = cycles
        self.profile = profile
        self.entries = entries
    }
}
