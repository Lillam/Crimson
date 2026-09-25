//
//  DataView.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import SwiftUI

struct DataSettingsView: View {
    var body: some View {
        Text("Data")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text("Your data is 100% local and won't ever be sent anywhere other than your phone. With that, your data can potentially grow to be a little large, you may wish to remove or export your data.")
            .font(.system(size: 12))
            .foregroundColor(.black.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
        CardView {
            VStack(alignment: .leading, spacing: 15) {
                Button(action: {  }) {
                    HStack {
                        Text("Export my data")
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.black)
                }
                Divider().overlay(.black.opacity(0.3))
                Button(action: { }) {
                    HStack {
                        Text("Erase my data")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.black)
                }
            }
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack (spacing: 20) {
        DataSettingsView()
    }
    .padding(20)
}
