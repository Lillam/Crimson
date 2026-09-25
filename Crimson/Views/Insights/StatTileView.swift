//
//  StatTileView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct StatTileView: View {
    let label: String
    let value: String
    let unit:  String
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black.opacity(0.75))
                Text(value)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

