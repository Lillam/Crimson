//
//  Collections.swift
//  Crimson
//
//  Created by Liam Taylor on 09/06/2026.
//

import Foundation

extension Collection where Element: BinaryInteger {
    /// Mean rounded to the nearest whole number, so a 27.86-day cycle projects
    /// as 28 rather than truncating to 27 and drifting a day every cycle.
     var average: Int {
         isEmpty ? 0 : Int((Double(reduce(0, +)) / Double(count)).rounded())
     }
 }
