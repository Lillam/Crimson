//
//  AppColor.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

extension Color {    
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

enum AppColor {
    static let ink = Color.adaptive(light: .black, dark: .white)

    static let page = Color.adaptive(
        light: .white,
        dark: Color(red: 24/255, green: 24/255, blue: 24/255)
    )

    static let card = Color.adaptive(
        light: .white,
        dark: Color(red: 38/255, green: 38/255, blue: 40/255)
    )
    
    static let track = Color.adaptive(
        light: Color(red: 241/255, green: 241/255, blue: 241/255),
        dark: Color(red: 0.22, green: 0.22, blue: 0.23)
    )
}
