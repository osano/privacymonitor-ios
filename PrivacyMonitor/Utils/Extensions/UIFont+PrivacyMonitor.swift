//
//  UIFont+PrivacyMonitor.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import UIKit

private enum LatoStyle: String {
    case regular = "Regular"
    case bold = "Bold"
    case black = "Black"
    case light = "Light"
    case hairline = "Hairline"

    var fontWeight: UIFont.Weight {
        switch self {
        case .bold:
            return .bold
        case .black:
            return .black
        case .light:
            return .light
        case .hairline:
            return .ultraLight
        default:
            return .regular
        }
    }
}

extension UIFont {

    class func privacyMonitorRegularFont(ofSize fontSize: CGFloat) -> UIFont {
        return latoFont(ofSize: fontSize, style: .regular)
    }

    class func privacyMonitorBoldFont(ofSize fontSize: CGFloat) -> UIFont {
        return latoFont(ofSize: fontSize, style: .bold)
    }

    class func privacyMonitorBlackFont(ofSize fontSize: CGFloat) -> UIFont {
        return latoFont(ofSize: fontSize, style: .black)
    }

    class func privacyMonitorLightFont(ofSize fontSize: CGFloat) -> UIFont {
        return latoFont(ofSize: fontSize, style: .light)
    }

    class func privacyMonitorHairlineFont(ofSize fontSize: CGFloat) -> UIFont {
        return latoFont(ofSize: fontSize, style: .hairline)
    }

    fileprivate class func latoFont(ofSize fontSize: CGFloat, style: LatoStyle) -> UIFont {
        guard let font = UIFont(name: "Lato-\(style.rawValue)", size: fontSize) else {
            return UIFont.systemFont(ofSize: fontSize, weight: style.fontWeight)
        }

        return font
    }
}
