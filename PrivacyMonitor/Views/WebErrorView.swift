//
//  WebErrorView.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

class WebErrorView: UIView {

    enum Metrics {
        static let layoutMargins = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    }

    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .privacyMonitorRegularFont(ofSize: 16.0)
        messageLabel.textColor = .primaryTextColor()
        return messageLabel
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        layoutMargins = WebErrorView.Metrics.layoutMargins

        addSubview(messageLabel)

        let constraints = [
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            messageLabel.trailingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -(UIScreen.main.bounds.height * 0.1))
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Public

    func configure(withMessage message: String) {
        messageLabel.text = message
    }
}
