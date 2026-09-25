//
//  CrimsonSchema.swift
//  Crimson
//
//  Created by Liam Taylor on 23/09/2026.
//

import Foundation
import SwiftData

/// Everything SwiftData persists, in one place. New `@Model` types get added
/// to `models`, and anything building a container reads it from here so the
/// app, the previews and the tests can't drift apart.
///
/// Nothing wires this up yet — it's here so that when a container is created,
/// it's a one-liner: `.modelContainer(for: CrimsonSchema.models)`.
enum CrimsonSchema {
    static let models: [any PersistentModel.Type] = [
        User.self,
        Cycle.self,
        DayLog.self,
    ]

    static var schema: Schema {
        Schema(models)
    }
}
