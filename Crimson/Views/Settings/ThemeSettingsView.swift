//
//  ThemeSettingsView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

struct ThemeSettingsView: View {
    @Environment(SettingsStore.self) var settings
    /// What the device is set to, so "System" can say which one it's
    /// currently following rather than leaving the user to guess.
    @Environment(\.colorScheme) private var deviceScheme

    /// Shared with the tab bar and the insights range picker.
    private let trackColor = AppColor.track

    private var systemDetail: String {
        settings.theme == .system
            ? "Following your device, currently \(deviceScheme == .dark ? "dark" : "light")."
            : "Choose System to follow your device's appearance."
    }

    var body: some View {
        Text("Theme")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(AppColor.ink)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text("How Crimson looks. System follows whatever your phone is set to, including when it switches itself at sunset.")
            .font(.system(size: 12))
            .foregroundColor(AppColor.ink.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 2) {
                ForEach(AppTheme.allCases) { theme in
                    let isSelected = theme == settings.theme

                    HStack(spacing: 10) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(theme.title)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(isSelected ? .white : AppColor.ink.opacity(0.75))
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.red : .clear, in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            settings.theme = theme
                        }
                    }
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(3)
            .background(trackColor, in: Capsule())
            .padding(5)
            .surface(Capsule())
            .sensoryFeedback(.selection, trigger: settings.theme)

            Text(systemDetail)
                .font(.system(size: 12))
                .foregroundColor(AppColor.ink.opacity(0.7))
        }
    }
}

#Preview(traits: .sampleData) {
    VStack(spacing: 20) {
        ThemeSettingsView()
    }
    .padding(20)
}
