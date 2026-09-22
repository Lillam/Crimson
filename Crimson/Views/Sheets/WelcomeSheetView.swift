//
//  WelcomeSheetView.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import SwiftUI

/// Welcome / profile editor: asks for a name to address the user by and,
/// optionally, a birthday (day and month only). Presented as a sheet, like the
/// donate page, so it can be swiped away — swiping counts as skipping.
///
/// Two places put it on screen: the app view on the very first run, and
/// Settings whenever the profile is edited. It closes itself either way, so
/// whoever presented it decides what dismissal means.
struct WelcomeSheetView: View {
    @Environment(ProfileStore.self) var profile
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var includesBirthday = false
    @State private var day: Int = 1
    @State private var month: Int = 1
    @FocusState private var nameFocused: Bool
    
    private let calendar = Calendar.current
    
    /// Days in the chosen month, allowing 29 for February since we don't know
    /// the year.
    private var daysInMonth: Int {
        switch month {
        case 2:            29
        case 4, 6, 9, 11:  30
        default:           31
        }
    }
    
    private var isReturning: Bool {
        profile.hasSeenWelcome || profile.displayName != nil
    }
    
    private func finish() {
        profile.name = name
        profile.birthday = includesBirthday ? Birthday(day: min(day, daysInMonth), month: month) : nil
        profile.completeWelcome()
        dismiss()
    }
    
    private func skip() {
        profile.completeWelcome()
        dismiss()
    }
    
    var body: some View {
        GeometryReader { geometry in
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: isReturning ? "person.text.rectangle.fill" : "hand.wave.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(isReturning ? "Welcome back" : "Welcome to Crimson")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    Text("Tell us a little about yourself. This is just so the app can talk to you like a person — you can change it any time in Settings.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What should we call you?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        TextField("Your name", text: $name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .focused($nameFocused)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 15)
                            .background(.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $includesBirthday.animation(.snappy(duration: 0.25))) {
                            Text("Add my birthday")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .tint(.white.opacity(0.35))
                        
                        if includesBirthday {
                            // Day first, then month. Menu pickers rather than
                            // wheels: side-by-side wheels fight over touches.
                            HStack(spacing: 10) {
                                pickerPill {
                                    Picker("Day", selection: $day) {
                                        ForEach(1...daysInMonth, id: \.self) { Text("\($0)").tag($0) }
                                    }
                                }
                                pickerPill {
                                    Picker("Month", selection: $month) {
                                        ForEach(1...12, id: \.self) { Text(calendar.monthSymbols[$0 - 1]).tag($0) }
                                    }
                                }
                                Spacer()
                            }
                            .onChange(of: month) {
                                // Clamp e.g. 31 → 30 when switching to a shorter month.
                                day = min(day, daysInMonth)
                            }
                            
                            Text("Just the day and month — we only use it to wish you a happy birthday!")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.top, 10)
                
                HStack(spacing: 15) {
                    Button(action: skip) {
                        Text(isReturning ? "Cancel" : "Skip for now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.15))
                            .cornerRadius(20)
                    }
                    
                    Button(action: finish) {
                        Text(isReturning ? "Save" : "Get started")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 30)
            .padding(.horizontal, 30)
            // Sits in the middle of the sheet while it fits, and scrolls
            // once the birthday pickers or the keyboard push it past.
            .frame(minHeight: geometry.size.height, alignment: .center)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
        .onTapGesture { nameFocused = false }
        .onAppear {
            // Prefill when coming back through from Settings.
            name = profile.name
            if let birthday = profile.birthday {
                includesBirthday = true
                day = birthday.day
                month = birthday.month
            }
        }
    }

    /// A white pill around a menu picker so it reads as a tappable field.
    @ViewBuilder
    private func pickerPill<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(.black)
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.white)
            .cornerRadius(12)
    }
}

#Preview {
    WelcomeSheetView()
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
}
