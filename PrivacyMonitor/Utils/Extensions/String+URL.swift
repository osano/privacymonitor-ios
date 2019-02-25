//
//  String+URL.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation

extension String {

    var asHTTPURL: URL? {
        guard !self.isEmpty else { return nil }

        if hasPrefix("https://") || hasPrefix("http://") {
            return URL(string: self)
        }
        else {
            let correctedURL = "http://\(self)"
            return URL(string: correctedURL)
        }
    }

    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
            return match.range.length == self.endIndex.encodedOffset
        }
        else {
            return false
        }
    }
}
