//
//  CardTitleView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct CardViewTitle: View {
    let title: String
    let icon: String
    let tint: Color
    let detail: String?
    let detailTint: Color?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(tint, in: RoundedRectangle(cornerRadius: 8))
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColor.ink)
            
            Spacer()
            
            if let detail {
                let pillTint = detailTint ?? .red
                
                Text(detail)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(pillTint)
                    .contentTransition(.numericText())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(pillTint.opacity(0.12), in: Capsule())
            }
        }
        .animation(.snappy(duration: 0.2), value: tint)
    }
}
