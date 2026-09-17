//
//  WelcomeView.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import SwiftUI

/// First-run welcome: asks for a name to address the user by and, optionally,
/// a birthday (day and month only). Presented as a full-screen cover so it
/// can't be swiped away, but it can always be skipped.
struct WelcomeView: View {
    @Environment(ProfileStore.self) var profile
    
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
    }
    
    private func skip() {
        profile.completeWelcome()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                Text(isReturning ? "Welcome back" : "Welcome to Crimson")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                Text("Tell us a little about yourself. This is just so the app can talk to you like a person — you can change it any time in Settings.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
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
            .padding(.top, 30)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(isReturning ? "Cancel" : "Skip for now", action: skip)
                    .font(.system(size: isReturning ? 16 : 14, weight: .medium))
                    .foregroundColor(isReturning ? .red : .white.opacity(0.8))
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(isReturning ? .white : .white.opacity(0))
                    .cornerRadius(20)
                
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
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
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
            .tint(.red)
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.white)
            .cornerRadius(12)
    }
}

#Preview {
    WelcomeView()
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
}
