//
//  UIImage+Tint.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    func tintedImage(usingColor color: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(origin: .zero, size: size))

        guard let tintedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()
        return tintedImage
    }
}
