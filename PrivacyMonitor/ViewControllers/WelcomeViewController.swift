//
//  WelcomeViewController.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet fileprivate weak var pageControl: UIPageControl!

    var welcomePageViewController: WelcomePageViewController? {
        didSet {
            welcomePageViewController?.welcomeDelegate = self
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomePageViewController = segue.destination as? WelcomePageViewController {
            self.welcomePageViewController = welcomePageViewController
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    // MARK: - Private

    fileprivate func finishWelcomeFlow() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        appDelegate.showMainApp(withWindow: appDelegate.window)

        UserSettingsHelper.setHasSeenWelcomeScreen(true)
    }
}

extension WelcomeViewController: WelcomePageViewControllerDelegate {

    func welcomePageViewController(welcomePageViewController: WelcomePageViewController, didTapPageActionButtonIndex index: Int) {
        switch index {
        case 0, 1:
            welcomePageViewController.scrollToViewController(index: index + 1)
        case 2:
            finishWelcomeFlow()
        default:
            break
        }
    }

    func welcomePageViewController(welcomePageViewController: WelcomePageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func welcomePageViewController(welcomePageViewController: WelcomePageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}
