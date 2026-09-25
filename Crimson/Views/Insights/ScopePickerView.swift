//
//  ScopePickerView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

/// The 3m / 6m / 12m switch above the daily-log cards.
///
/// Built rather than `.pickerStyle(.segmented)`: colouring that means going
/// through `UISegmentedControl.appearance()`, which is a global change to
/// every segmented control in the app to style the one. This is the same
/// capsule-in-a-capsule the floating tab bar uses, so the two agree.
struct ScopePickerView: View {
    @Binding var scope: InsightsScope

    /// Shared with the tab bar.
    static let trackColor = AppColor.page

    var body: some View {
        HStack(spacing: 2) {
            ForEach(InsightsScope.allCases) { option in
                let isSelected = option == scope

                Text(option.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : AppColor.ink.opacity(0.75))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(isSelected ? Color.red : .clear, in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            scope = option
                        }
                    }
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(3)
        .background(Self.trackColor, in: Capsule())
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColor.ink.opacity(0.07), lineWidth: 1)
        }
        .sensoryFeedback(.selection, trigger: scope)
    }
}

#Preview {
    @Previewable @State var scope: InsightsScope = .twelveMonths

    return VStack(spacing: 20) {
        ScopePickerView(scope: $scope)
        Text("selected: \(scope.phrase)")
            .font(.system(size: 13))
            .foregroundColor(AppColor.ink.opacity(0.7))
    }
    .padding(20)
}
