//
//  DeleteDataSheet.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct DeleteDataSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // give this sheet access to all the stores so that when the user
    // decides they would like to delete anything it's going to come
    // out of the database that these stores control.
    @Environment(CycleStore.self) private var cycleStore
    @Environment(DayLogStore.self) private var dayLogStore
    @Environment(ProfileStore.self) private var profielStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "trash")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
                Text("Delete Your Data")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                Text("Your data is yours to control, you can delete what you would like to delete!")
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    SheetButton(
                        title: "Delete All My Data",
                        description: "This option will completely nuke the application removing all data you've entered since creation. Cycles, Days, Profile.",
                        icon: "globe",
                        iconSecondary: "trash",
                        action: deleteAllMyData
                    )
                    
                    SheetButton(
                        title: "Delete Day Logs",
                        description: "This option will delete all your entries where you've logged symptoms, mood, energy etc.",
                        icon: "book",
                        iconSecondary: "trash",
                        action: deleteDayLogData
                    )
                    
                    SheetButton(
                        title: "Delete Cycles",
                        description: "This option will delete all your cycle data, how frequent you are, how long your cycles are.",
                        icon: "repeat",
                        iconSecondary: "trash",
                        action: deleteCycleData
                    )
                    
                    SheetButton(
                        title: "Delete Profile",
                        description: "This option will delete your profile, in doing this you will spark the application to ask who you are again, but if you don't care to add it - you don't have to.",
                        icon: "person.fill",
                        iconSecondary: "trash",
                        action: deleteProfileData
                    )
                }
                
                Button(action: { dismiss() }) {
                    Text("Nevermind")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.15))
                        .cornerRadius(20)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(30)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
    }
    
    private func deleteAllMyData () -> Void {
        deleteDayLogData()
        deleteCycleData()
        deleteProfileData()
    }
    
    private func deleteDayLogData() -> Void {
        print("day log data deleted...")
    }
    
    private func deleteCycleData() -> Void {
        print("cycle data deleted...")
    }
    
    private func deleteProfileData() -> Void {
        print("profile data deleted...")
    }
}

#Preview(traits: .sampleData) {
    DeleteDataSheet()
}
