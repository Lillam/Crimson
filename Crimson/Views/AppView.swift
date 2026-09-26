//
//  AppView.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import SwiftUI

struct AppView: View {
    @Environment(Router.self) var router
    @Environment(ProfileStore.self) var profile
    
    /// How far the keyboard overlaps the page, in points. We opt the whole
    /// screen out of SwiftUI's keyboard avoidance and re-apply this as
    /// safe-area padding on the page instead. Same avoidance, but the page
    /// now extends underneath the keyboard, so its content shows through
    /// the keyboard's rounded corners instead of a blank root background —
    /// and the floating bar simply stays put beneath the keyboard.
    @State private var keyboardOverlap: CGFloat = 0
    
    var body: some View {
        @Bindable var profile = profile

        GeometryReader { geometry in
        ZStack(alignment: .bottom) {
            // Active page fills the whole screen, behind the bar
            VStack {
                switch router.currentRoute {
                case .calendar:      CalendarView()
                case .day(let date): DayView(selected: toDate(date))
                case .insights:      InsightsView()
                case .settings:      SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(.bottom, keyboardOverlap)

            // Floating pill tab bar
            HStack {
                ForEach(Route.allCases, id: \.self) { route in
                    let isSelected = router.isCurrent(route)

                    VStack(spacing: 5) {
                        Image(systemName: route.icon)
                            .font(.system(size: 18, weight: .semibold))
                        Text(route.id.ucFirst.removingDotSuffix)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(isSelected ? .white : AppColor.ink)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(
                        isSelected ? Color.red : .clear,
                        in: Capsule()
                    )
                    .contentShape(Capsule())
                    .animation(.snappy(duration: 0.25), value: isSelected)
                    .onTapGesture {
                        router.navigate(to: route)
                    }
                }
            }
            .padding(6)
            .frame(maxWidth: .infinity)
            .background(AppColor.track, in: Capsule())
            .shadow(color: AppColor.ink.opacity(0.15), radius: 8, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, -10)
            .allowsHitTesting(keyboardOverlap == 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            // The keyboard frame is in screen coordinates; how much of it
            // sits above the bottom of our (safe-area-inset) page is what
            // the page needs to make room for. A hidden keyboard reports a
            // frame below the screen, giving zero.
            let overlap = max(geometry.frame(in: .global).maxY - frame.minY, 0)
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardOverlap = overlap
            }
        }
        }
        .ignoresSafeArea(.keyboard)
        .background(AppColor.page.ignoresSafeArea())
        // On the first run only, show the user a sheet which will be a welcome
        // sheet to the application. This is possible to be swiped away and
        // skipped/ignored. And regardless of how it's closed, it will always
        // create the user with empty values allowing the user to modify this
        // in the settings page later, whenever they desire it.
        .sheet(isPresented: Binding(
            get: {
                !profile.hasProfile
            },
            // Regardless of how this was closed, we're going to want to create
            // the user so that this sheet never shows again.
            set: { presented in
                if !presented {
                    profile.createProfile()
                }
            }
        )) {
            WelcomeSheetView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview(traits: .sampleData) {
    AppView()
}
