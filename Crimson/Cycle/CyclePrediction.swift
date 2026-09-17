//
//  CyclePrediction.swift
//  Crimson
//
//  Created by Liam Taylor on 08/06/2026.
//

import Foundation

struct CyclePrediction {
    let windowStart: Date // earliest likely next period start
    let windowEnd: Date   // latest likely next period start
    let expected: Date    // mid-point / best single guess.
    let confidence: Confidence
    
    enum Confidence {
        case low, medium, high
    }
}
