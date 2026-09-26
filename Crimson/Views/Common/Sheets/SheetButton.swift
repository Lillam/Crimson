//
//  SheetButton.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct SheetButton: View {
    var title: String
    var description: String
    var icon: String
    var iconSecondary: String = "arrow.up.right"
    var action: () -> Void
        
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
                    .background(.white, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: iconSecondary)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.16))
            .cornerRadius(20)
        }
    }
}

#Preview {
    VStack {
        SheetButton(
            title: "Delete your data",
            description: "Yoru data is your own to delete",
            icon: "globe",
            action: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(20)
    .background(.red)
}
