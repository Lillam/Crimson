//
//  DayMoodView.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import SwiftUI

struct DayMoodView: View {
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 20) {
                CardViewTitle(
                    title: "Mood",
                    icon: "face.smiling",
                    tint: .red,
                    detail: "Happy",
                    detailTint: .red
                )
            }
        }
    }
}

//scaleCard("Mood", icon: "face.smiling", selection: field(\.mood))

//VStack(alignment: .leading, spacing: 14) {
//    CardViewTitle(
//        title: title,
//        icon: icon,
//        tint: chosen?.tint ?? .red,
//        detail: chosen?.title,
//        detailTint: chosen?.tint
//    )
//    
//    HStack(spacing: 4) {
//        ForEach(Array(Option.allCases)) { step in
//            let tint = step.tint
//            let isSelected = chosen == step
//            // Once something's chosen the rest step back, so the
//            // answer stands out from a glance at the page.
//            let isDimmed = chosen != nil && !isSelected
//            
//            Button {
//                notesFocused.wrappedValue = false
//                // Tapping the current choice clears it.
//                selection.wrappedValue = isSelected ? nil : step
//            } label: {
//                VStack(spacing: 6) {
//                    Text(step.emoji)
//                        .font(.system(size: isSelected ? 28 : 22))
//                        .frame(width: 46, height: 46)
//                        .background {
//                            Circle()
//                                .fill(tint.opacity(isSelected ? 1 : 0.16))
//                        }
//                        .overlay {
//                            Circle()
//                                .stroke(tint.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
//                        }
//                        .shadow(color: tint.opacity(isSelected ? 0.35 : 0), radius: 6, y: 3)
//                    
//                    Text(step.title)
//                        .font(.system(size: 10, weight: isSelected ? .bold : .medium))
//                        .foregroundColor(isSelected ? tint : .black.opacity(0.55))
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.7)
//                }
//                .opacity(isDimmed ? 0.5 : 1)
//                .scaleEffect(isSelected ? 1.04 : 1)
//            }
//            .frame(maxWidth: .infinity)
//            .accessibilityLabel(step.title)
//        }
//    }
//    .animation(.snappy(duration: 0.25), value: chosen)
//}

#Preview {
    VStack {
        DayMoodView()
    }
    .padding(20)
}
