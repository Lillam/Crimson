//
//  SettingsView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(ProfileStore.self) var profile
    @State private var confirmingDelete = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            
            Text("Profile")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text("Editing takes you back through the welcome screen.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 0) {
                row("Name", value: profile.displayName ?? "Not set")
                Divider().overlay(.white.opacity(0.3))
                row("Birthday", value: profile.birthday?.formatted ?? "Not set")
                Divider().overlay(.white.opacity(0.3))
                
                // Re-running the welcome is how the profile gets edited, so
                // there's one place that knows how to collect it.
                Button(action: profile.showWelcomeAgain) {
                    HStack {
                        Text("Edit profile")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 15)
                }
                
                Button(action: { confirmingDelete = true }) {
                    HStack {
                        Text("Delete profile")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 15)
                }
                .padding(.top, 10)
                .confirmationDialog(
                    "Delete your profile?",
                    isPresented: $confirmingDelete,
                    titleVisibility: .visible
                ) {
                    Button("Delete profile", role: .destructive, action: profile.deleteProfile)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Your name and birthday will be removed, and you'll be taken through the welcome screen again the next time you open the app. Your logged periods are not affected.")
                }
            }
            .background(.white.opacity(0.05))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(.red)
    }
    
    @ViewBuilder
    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(size: 16))
        .padding(.vertical, 14)
        .padding(.horizontal, 15)
    }
}

#Preview {
    SettingsView()
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
}
