//
//  CardView.swift
//  Crimson
//
//  Created by Liam Taylor on 22/09/2026.
//

import SwiftUI

struct CardView<Content: View>: View {
    private let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.black.opacity(0.07), lineWidth: 1)
            }
    }
}
