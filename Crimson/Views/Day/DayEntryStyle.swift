//
//  DayEntryStyle.swift
//  Crimson
//
//  Created by Liam Taylor on 21/09/2026.
//

import SwiftUI

// How the day log's options are drawn. Kept out of `DayLog` so the model stays
// plain Foundation + SwiftData — nothing saved to disk depends on any of this,
// and an icon or a colour can change without touching stored data.

extension DayLog.Flow {
    /// An outline, then a half drop, a full one, and finally a cluster —
    /// the row reads as a scale even before the labels are.
    var icon: String {
        switch self {
        case .spotting: "drop"
        case .light:    "drop.halffull"
        case .medium:   "drop.fill"
        case .heavy:    "humidity.fill"
        }
    }

    /// Pink through to a deep crimson — the app's red is the heavy end.
    var tint: Color {
        switch self {
        case .spotting: Color(red: 0.91, green: 0.53, blue: 0.60)
        case .light:    Color(red: 0.87, green: 0.36, blue: 0.44)
        case .medium:   Color(red: 0.78, green: 0.19, blue: 0.27)
        case .heavy:    Color(red: 0.58, green: 0.09, blue: 0.16)
        }
    }
}

extension DayLog.Symptom {
    var icon: String {
        switch self {
        case .cramps:        "bolt.heart.fill"
        case .headache:      "brain.head.profile"
        case .bloating:      "wind"
        case .tenderBreasts: "heart.fill"
        case .fatigue:       "battery.25percent"
        case .backPain:      "figure.walk"
        case .acne:          "circle.hexagongrid.fill"
        case .nausea:        "face.dashed"
        case .cravings:      "fork.knife"
        case .insomnia:      "moon.zzz.fill"
        }
    }

    /// One hue each, muted enough to sit beside the app's red without
    /// fighting it. Grouped loosely by where the symptom is felt: aches warm,
    /// head and sleep cool, gut green.
    var tint: Color {
        switch self {
        case .cramps:        Color(red: 0.80, green: 0.25, blue: 0.33)
        case .headache:      Color(red: 0.51, green: 0.36, blue: 0.72)
        case .bloating:      Color(red: 0.24, green: 0.56, blue: 0.62)
        case .tenderBreasts: Color(red: 0.85, green: 0.38, blue: 0.56)
        case .fatigue:       Color(red: 0.45, green: 0.47, blue: 0.62)
        case .backPain:      Color(red: 0.84, green: 0.48, blue: 0.22)
        case .acne:          Color(red: 0.72, green: 0.52, blue: 0.29)
        case .nausea:        Color(red: 0.31, green: 0.58, blue: 0.40)
        case .cravings:      Color(red: 0.87, green: 0.62, blue: 0.20)
        case .insomnia:      Color(red: 0.35, green: 0.42, blue: 0.70)
        }
    }
}

// MARK: - The five-point scales

/// What the mood and energy rows need to draw themselves. Both scales share it
/// so one card can render either, and so a "middling" answer is the same shade
/// whichever row it's on.
protocol DayLogScale: CaseIterable, Identifiable, Hashable {
    var title: String { get }
    var emoji: String { get }
    var tint: Color { get }
}

/// Low to high: slate, violet, amber, teal, green.
enum ScaleTint {
    static let steps: [Color] = [
        Color(red: 0.45, green: 0.50, blue: 0.64),
        Color(red: 0.56, green: 0.45, blue: 0.69),
        Color(red: 0.83, green: 0.62, blue: 0.27),
        Color(red: 0.36, green: 0.65, blue: 0.55),
        Color(red: 0.26, green: 0.60, blue: 0.38),
    ]

    static func step(_ index: Int) -> Color {
        steps[max(0, min(index, steps.count - 1))]
    }
}

extension DayLog.Mood: DayLogScale {
    var tint: Color {
        switch self {
        case .rough: ScaleTint.step(0)
        case .low:   ScaleTint.step(1)
        case .okay:  ScaleTint.step(2)
        case .good:  ScaleTint.step(3)
        case .great: ScaleTint.step(4)
        }
    }
}

extension DayLog.Energy: DayLogScale {
    var tint: Color {
        switch self {
        case .drained:   ScaleTint.step(0)
        case .tired:     ScaleTint.step(1)
        case .steady:    ScaleTint.step(2)
        case .lively:    ScaleTint.step(3)
        case .energetic: ScaleTint.step(4)
        }
    }
}
