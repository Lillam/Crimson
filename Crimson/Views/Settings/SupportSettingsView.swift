//
//  SupportView.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import SwiftUI

struct SupportSettingsView: View {
    @State private var showingDonate: Bool = false
    
    var body: some View {
        Text("Support")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(AppColor.ink)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text("Crimson is free and always will be. If you'd like to chip in, here's where.")
            .font(.system(size: 12))
            .foregroundColor(AppColor.ink.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: { showingDonate = true }) {
                    HStack {
                        Text("Feeling generous?")
                        Spacer()
                        Image(systemName: "heart")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.ink)
                }
            }
        }
        .sheet(isPresented: $showingDonate) {
            FeelingGenerousSheetView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview(traits: .sampleData) {
    VStack (spacing: 20) {
        SupportSettingsView()
    }
    .padding(20)
}
