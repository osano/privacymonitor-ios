//
//  UIColor+PrivacyMonitor.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import UIKit

extension UIColor {

    class func primaryTintColor() -> UIColor {
        return UIColor(red: 2.0 / 255.0, green: 206.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    class func secondaryTintColor() -> UIColor {
        return UIColor(red: 13.0 / 255.0, green: 120.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
    }

    class func primaryTextColor() -> UIColor {
        return UIColor(white: 64.0 / 255.0, alpha: 1.0)
    }

    class func blueTextColor() -> UIColor {
        return UIColor(red: 13.0 / 255.0, green: 120.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
    }

    class func scoreVeryPoorColor() -> UIColor {
        return UIColor(red: 195.0 / 255.0, green: 62.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0)
    }

    class func scoreFairColor() -> UIColor {
        return UIColor(red: 159.0 / 255.0, green: 51.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    }

    class func scoreGoodColor() -> UIColor {
        return UIColor(red: 103.0 / 255.0, green: 41.0 / 255.0, blue: 118.0 / 255.0, alpha: 1.0)
    }

    class func scoreVeryGoodColor() -> UIColor {
        return UIColor(red: 50.0 / 255.0, green: 109.0 / 255.0, blue: 177.0 / 255.0, alpha: 1.0)
    }

    class func scoreExceptionalColor() -> UIColor {
        return UIColor(red: 26.0 / 255.0, green: 70.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
    }

    class func trendImprovingColor() -> UIColor {
        return UIColor(red: 66.0 / 255.0, green: 176.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
    }

    class func trendDecliningColor() -> UIColor {
        return UIColor(red: 230.0 / 255.0, green: 69.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
    }

    class func trendNoChangeColor() -> UIColor {
        return UIColor(white: 182.0 / 255.0, alpha: 1.0)
    }

    class func searchTextFieldBackgroundColor() -> UIColor {
        return UIColor(white: 238.0 / 255.0, alpha: 1.0)
    }

    class func toolTipBackgroundColor() -> UIColor {
        return UIColor(white: 1.0, alpha: 0.98)
    }

    class func scoreTipCircleBackgroundColor() -> UIColor {
        return UIColor(red: 223.0 / 255.0, green: 223.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    }

    class func searchViewBorderColor() -> UIColor {
        return UIColor(white: 233 / 255.0, alpha: 1.0)
    }
}
