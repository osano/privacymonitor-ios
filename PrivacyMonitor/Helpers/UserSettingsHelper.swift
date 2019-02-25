//
//  UserSettingsHelper.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation

struct UserSettingsHelper {

    // MARK: - Welcome screen

    static func hasSeenWelcomeScreen() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.UserDefaults.hasSeenWelcomeScreenKey)
    }

    static func setHasSeenWelcomeScreen(_ seen: Bool) {
        UserDefaults.standard.set(seen, forKey: Constants.UserDefaults.hasSeenWelcomeScreenKey)
    }

    // MARK: - User Favorites

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [Constants.UserDefaults.favoritesArrayKey: [String]()])
    }

    static func saveFavoriteURL(_ urlString: String) {
        guard var favorites = UserDefaults.standard.array(forKey: Constants.UserDefaults.favoritesArrayKey) as? [String] else { return }

        if !favorites.contains(urlString) {
            favorites.append(urlString)
            UserDefaults.standard.set(favorites, forKey: Constants.UserDefaults.favoritesArrayKey)
        }
    }

    static func removeFavoriteURL(_ urlString: String) {
        guard var favorites = UserDefaults.standard.array(forKey: Constants.UserDefaults.favoritesArrayKey) as? [String] else { return }

        favorites.removeAll { $0 == urlString }

        UserDefaults.standard.set(favorites, forKey: Constants.UserDefaults.favoritesArrayKey)
    }

    static func favoritesUrls() -> [String]? {
        return UserDefaults.standard.array(forKey: Constants.UserDefaults.favoritesArrayKey) as? [String]
    }
}
