//
//  SettingsView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {                
                    ProfileSettingsView()
                    CalendarSettingsView()
                    DataSettingsView()
                    SupportSettingsView()
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, 70)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .background(.white)        
    }

}

#Preview {
    SettingsView()
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
        .environment(SettingsStore(defaults: UserDefaults(suiteName: "preview")!))
}
