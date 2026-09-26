//
//  PageTitle.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct PageTitle: View {
    var title: String
    var subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppColor.ink)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.ink.opacity(0.75))
            }
        }
        .padding(.top, 50)
    }
}
