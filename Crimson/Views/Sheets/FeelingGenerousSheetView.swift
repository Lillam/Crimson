//
//  FeelingGenerousSheetView.swift
//  Crimson
//
//  Created by Liam Taylor on 21/09/2026.
//

import SwiftUI

/// One way to send a few quid our way. `url` is what makes it appear —
/// an option with no link is simply left out of the page, so the list can be
/// filled in one account at a time.
struct DonationOption: Identifiable {
    var id: String { title }
    let title: String
    let detail: String
    let icon: String
    let url: URL?
}

extension DonationOption {
    /// Swap these for the real accounts. Anything still pointing at a
    /// placeholder handle can have its `url` set to `nil` to hide the row
    /// until it's ready.
    static let all: [DonationOption] = [
        DonationOption(
            title: "Buy us a coffee",
            detail: "A one-off tip, about the price of a flat white.",
            icon: "cup.and.saucer.fill",
            url: URL(string: "https://buymeacoffee.com/your-handle")
        ),
        DonationOption(
            title: "Ko-fi",
            detail: "One-off or monthly, whatever suits you.",
            icon: "heart.fill",
            url: URL(string: "https://ko-fi.com/your-handle")
        ),
        DonationOption(
            title: "PayPal",
            detail: "Straight to liam who builds this in his own time.",
            icon: "creditcard.fill",
            url: URL(string: "https://paypal.me/your-handle")
        ),
    ]

    static var available: [DonationOption] {
        all.filter { $0.url != nil }
    }
}

/// The "feeling generous?" page. Purely informational — nothing here charges
/// anyone, it just points at the places a donation can be made. Reached from
/// Settings and presented as a sheet, so it can always be swiped away.
struct FeelingGenerousSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileStore.self) var profile

    private var options: [DonationOption] {
        DonationOption.available
    }

    /// "Feeling generous, Liam?" when we know the name, and a plain ask when
    /// we don't.
    private var title: String {
        if let name = profile.displayName {
            return "Feeling generous, \(name)?"
        }

        return "Feeling generous?"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    Text("Crimson is and always will be free without ads and your data will not be sold - that's a promise. The only place your data exists; is on your phone.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                    Text("If this has been useful to you, and you can spare it, a donation keeps the developer account paid for and this app hosted. I will be keeping this up out of my own pocket.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                }

                
                VStack(spacing: 10) {
                    ForEach(options) { option in
                        optionRow(option)
                    }
                }

                Text("Donations are a thank you, not a purchase there's nothing to unlock, and every part of the app stays available to everyone at all times.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))

                Button(action: { dismiss() }) {
                    Text("Maybe another time")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.15))
                        .cornerRadius(20)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 30)
            .padding(.horizontal, 30)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
    }

    /// A tappable card that hands the link off to the browser. `Link` rather
    /// than a button so long-press previews and "open in" behave as expected.
    @ViewBuilder
    private func optionRow(_ option: DonationOption) -> some View {
        if let url = option.url {
            Link(destination: url) {
                HStack(spacing: 14) {
                    Image(systemName: option.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        .background(.white, in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text(option.detail)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.12))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    FeelingGenerousSheetView()
        .environment(ProfileStore(defaults: UserDefaults(suiteName: "preview")!))
}
