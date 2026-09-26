//
//  ProfileStore.swift
//  Crimson
//
//  Created by Liam Taylor on 17/09/2026.
//

import SwiftData
import Foundation

@Observable final class ProfileStore: Store<User> {
    private(set) var profile: User?

    override func load() {
        profile = first()
    }

    /// Whether they've been through the welcome at all.
    var hasProfile: Bool {
        profile != nil
    }

    /// The profile to read for display.
    ///
    /// Hands back a blank, *un-inserted* `User` when there isn't one yet, so
    /// that merely rendering the settings page doesn't create a row and
    /// silently dismiss the welcome. Writes go through `update` instead.
    func getProfile() -> User {
        profile ?? User()
    }

    /// Makes sure a row exists, so the welcome doesn't ask again.
    ///
    /// Idempotent: closing the sheet twice, or skipping after saving, can't
    /// produce a second profile.
    @discardableResult
    func createProfile() -> User? {
        guard profile == nil else {
            return profile
        }

        do {
            try insert(User())
        } catch {
            assertionFailure("Could not create the profile: \(error)")
        }

        return profile
    }

    /// Writes the name and birthday, creating the row first if this is the
    /// first time through the welcome.
    func update(name: String, birthday: User.Birthday?) {
        guard let profile = createProfile() else {
            return
        }

        profile.name = name
        profile.birthday = birthday

        save(reload: true)
    }

    /// Forgets them entirely. The welcome will ask again, because there's no
    /// longer a row to say otherwise.
    func deleteProfile() {
        guard let profile else {
            return
        }

        context.delete(profile)
        save(reload: true)
    }
}
