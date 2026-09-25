//
//  ViewExtensions.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

extension View {
    func surface<S: InsettableShape>(_ shape: S, fill: Color = AppColor.card) -> some View {
        background(fill, in: shape)
            .overlay(shape.strokeBorder(AppColor.ink.opacity(0.07), lineWidth: 1))
    }
}
