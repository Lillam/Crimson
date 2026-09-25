//
//  PhaseStyle.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

// How each cycle phase is coloured. Kept out of `CyclePhase` so the engine
// stays plain Foundation — nothing the maths does depends on any of this.

extension CyclePhase {
    /// Red through to indigo, walking the cycle from the period itself to the
    /// wind-down before the next one.
    ///
    /// The ramp is hue-led rather than a set of reds on purpose: four reds
    /// distinguishable from each other would need the lightest to go pale,
    /// and white text on a pale red doesn't hold up. Fertile is the brightest
    /// because it's the stretch people actually scan for, and it's separated
    /// from luteal by lightness as well as hue — hue alone collapses the two
    /// into the same blue for anyone with deuteranopia.
    var tint: Color {
        switch self {
        case .menstrual:  Color(.red).opacity(0.85)
        case .follicular: Color(.magenta)
        case .fertile:    Color(.purple)
        case .luteal:     Color(.indigo)
        }
    }
}

extension CyclePosition {
    /// What the phase card should be drawn in.
    ///
    /// A late cycle is the one state where the colour has a job to do, so it
    /// overrides the phase: luteal indigo reads as calm, which is the opposite
    /// of what an overdue period means. Red is the phase colour for menstrual,
    /// which is roughly what "late" is waiting on anyway.
    var tint: Color {
        daysLate > 0 ? .red : phase.tint
    }
}
