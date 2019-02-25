//
//  DomainViewModel.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import PrivacyMonitorFramework
import UIKit

enum Trend: String {
    case undefined = "No History"
    case noChange = "No Change"
    case declining = "Declining"
    case improving = "Improving"
}

enum Score: String {
    case unknown = "Unknown"
    case veryPoor = "Very Poor"
    case fair = "Fair"
    case good = "Good"
    case veryGood = "Very Good"
    case exceptional = "Exceptional"
}

extension Score {
    init(score: Int) {
        switch score {
        case 300...579:
            self = .veryPoor
        case 580...669:
            self = .fair
        case 670...739:
            self = .good
        case 740...799:
            self = .veryGood
        case 800...850:
            self = .exceptional
        default:
            self = .unknown
        }
    }
}

enum TrendDescriptionFormat {
    case space
    case newLine
}

struct DomainViewModel {
    let domain: Domain

    init(domain: Domain) {
        self.domain = domain
    }
}

extension DomainViewModel {

    var rootDomain: String? {
        return domain.rootDomain
    }

    var score: Int {
        return domain.score
    }

    var previousScore: Int? {
        return domain.previousScore
    }

    var capitalizedRootDomain: String? {
        guard let rootDomain = domain.rootDomain else { return nil }

        return rootDomain.prefix(1).uppercased() + rootDomain.lowercased().dropFirst()
    }

    var scoreNumberDescription: String {
        return "Score: \(domain.score)"
    }

    var scoreDescription: String {
        return Score(score: domain.score).rawValue
    }

    var scoreDescriptionLarge: String {
        return "\(domain.score) - \(scoreDescription)"
    }

    var scoreColor: UIColor {
        switch Score(score: domain.score) {
        case .veryPoor:
            return .scoreVeryPoorColor()
        case .fair:
            return .scoreFairColor()
        case .good:
            return .scoreGoodColor()
        case .veryGood:
            return .scoreVeryGoodColor()
        case .exceptional:
            return .scoreExceptionalColor()
        default:
            return .trendNoChangeColor()
        }
    }

    var trend: Trend {
        guard domain.previousScore > 0 else {
            return .undefined
        }

        if domain.score > domain.previousScore {
            return .improving
        }
        else if domain.score < domain.previousScore {
            return .declining
        }
        return .noChange
    }

    var trendColor: UIColor {
        switch trend {
        case .undefined, .noChange:
            return .trendNoChangeColor()
        case .improving:
            return .trendImprovingColor()
        case .declining:
            return .trendDecliningColor()
        }
    }

    var trendImage: UIImage? {
        switch trend {
        case .undefined, .noChange:
            return #imageLiteral(resourceName: "TrendNoChangeIcon").tintedImage(usingColor: trendColor)
        case .improving:
            return #imageLiteral(resourceName: "TrendImprovingIcon").tintedImage(usingColor: trendColor)
        case .declining:
            return #imageLiteral(resourceName: "TrendDecliningIcon").tintedImage(usingColor: trendColor)
        }
    }

    // MARK: - Helpers

    func attributtedTrendString(format: TrendDescriptionFormat = .space, fontSize: CGFloat = 15.0) -> NSAttributedString {
        var trendColor = UIColor.primaryTextColor()
        switch trend {
        case .undefined, .noChange:
            trendColor = .trendNoChangeColor()
        case .improving:
            trendColor = .trendImprovingColor()
        case .declining:
            trendColor = .trendDecliningColor()
        }

        var separator = " "
        if format == .newLine {
            separator.append("\n")
        }

        let regularAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryTextColor(), .font: UIFont.privacyMonitorRegularFont(ofSize: fontSize)]
        let trendAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: trendColor, .font: UIFont.privacyMonitorBoldFont(ofSize: fontSize)]

        let attributtedString = NSMutableAttributedString(string: "Trend:\(separator)", attributes: regularAttributes)
        attributtedString.append(NSAttributedString(string: trend.rawValue, attributes: trendAttributes))

        return attributtedString
    }
}
