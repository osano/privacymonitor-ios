//
//  Configs.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation

struct Configs {

    struct App {
        static let bundleIdentifier = "com.osano.PrivacyMonitor"
    }
}

struct Constants {

    struct App {
        static let initialURL = "https://www.privacymonitor.com/welcome/ios"
        static let redirectURL = "https://duckduckgo.com/?q="
        static let blankPageURL = "about:blank"
        static let scoreAnalysisSuccessText = "Your request has been received and will be handled in the order received."
    }

    struct ErrorMessages {
        static let unknown = "An unknown error has occured."
        static let cannotFindHost = "Privacy Monitor by Osano cannot open the page because the server cannot be found."
        static let domainDoesNotExist = "No score found for this site."
    }

    struct UserDefaults {
        static let hasSeenWelcomeScreenKey = "userDefaultsHasSeenWelcomeScreenKey"
        static let favoritesArrayKey = "favoritesArrayKey"
    }

    struct StoryboardID {
        static let welcome = "Welcome"
        static let webView = "WebView"
    }
}
