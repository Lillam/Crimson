//
//  Profile.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(ProfileStore.self) var profile
    @State private var editingProfile = false
    @State private var confirmingDelete = false
        
    var body: some View {
        Text("Profile")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(AppColor.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text("Editing opens the welcome screen again, right here.")
            .font(.system(size: 12))
            .foregroundColor(AppColor.ink.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
        CardView {
            VStack(spacing: 15) {
                HStack {
                    Text("Name")
                        .foregroundColor(AppColor.ink)
                    Spacer()
                    Text(profile.displayName ?? "Not Set")
                        .foregroundColor(AppColor.ink)
                }
                Divider().overlay(AppColor.ink.opacity(0.3))
                HStack {
                    Text("Birthday")
                        .foregroundColor(AppColor.ink)
                    Spacer()
                    Text(profile.birthday?.formatted ?? "Not Set")
                        .foregroundColor(AppColor.ink)
                }
                Divider().overlay(AppColor.ink.opacity(0.3))
                Button(action: { editingProfile = true }) {
                    HStack {
                        Text("Edit")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(AppColor.ink)
                }
                Divider().overlay(AppColor.ink.opacity(0.3))
                Button(action: { confirmingDelete = true }) {
                    HStack {
                        Text("Delete profile")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .foregroundColor(AppColor.ink)
                }
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
        }
        .sheet(isPresented: $editingProfile) {
            WelcomeSheetView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview(traits: .sampleData) {
    VStack (spacing: 20) {
        ProfileSettingsView()
    }.padding(20)
}
