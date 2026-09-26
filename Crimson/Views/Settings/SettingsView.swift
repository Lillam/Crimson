//
//  SettingsView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageTitle(title: "Settings")
                ProfileSettingsView()
                ThemeSettingsView()
                CalendarSettingsView()
                DataSettingsView()
                SupportSettingsView()
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .background(AppColor.page)
        .ignoresSafeArea()
    }
}

#Preview(traits: .sampleData) {
    SettingsView()
}
