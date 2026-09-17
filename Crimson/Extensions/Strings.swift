//
//  Strings.swift
//  Crimson
//
//  Created by Liam Taylor on 08/06/2026.
//

import Foundation

extension String {
    var ucFirst: String {
        guard let first else {
            return self
        }
        
        return first.uppercased() + dropFirst()
    }
    
    var removingDotSuffix: String {
        replacing(/\..*/, with: "")
    }
}
