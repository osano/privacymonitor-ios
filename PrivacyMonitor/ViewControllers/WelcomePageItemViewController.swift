//
//  WelcomePageItemViewController.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

protocol WelcomePageItemViewControllerDelegate: AnyObject {
    func didTapActionButton(welcomePageItemViewController: WelcomePageItemViewController)
}

class WelcomePageItemViewController: UIViewController {

    weak var delegate: WelcomePageItemViewControllerDelegate?

    // MARK: - User Interaction

    @IBAction fileprivate func actionButtonTapped(_ sender: Any) {
        delegate?.didTapActionButton(welcomePageItemViewController: self)
    }
}
