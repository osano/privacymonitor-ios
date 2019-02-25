//
//  AddToFavoritesActivity.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

extension UIActivity.ActivityType {
    static let privacyMonitor = UIActivity.ActivityType("com.osano.privacymonitor")
}

class AddToFavoritesActivity: UIActivity {

    var urlToSave: URL?

    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return .privacyMonitor
    }

    override var activityTitle: String? {
        return "Add to Favorites"
    }

    override var activityImage: UIImage? {
        return #imageLiteral(resourceName: "AddFavoriteIcon")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for case is URL in activityItems {
            return true
        }

        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for case let url as URL in activityItems {
            self.urlToSave = url
            return
        }
    }

    override func perform() {
        guard let urlToSave = urlToSave, let host = urlToSave.host else { return }

        UserSettingsHelper.saveFavoriteURL(host)
        activityDidFinish(true)
    }
}
