//
//  WelcomePageViewController.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

private enum WelcomeViewControllerPage: String, CaseIterable {
    case firstPage = "FirstPageViewController"
    case secondPage = "SecondPageViewController"
    case thirdPage = "ThirdPageViewController"
}

protocol WelcomePageViewControllerDelegate: AnyObject {
    func welcomePageViewController(welcomePageViewController: WelcomePageViewController, didUpdatePageCount count: Int)
    func welcomePageViewController(welcomePageViewController: WelcomePageViewController, didUpdatePageIndex index: Int)
    func welcomePageViewController(welcomePageViewController: WelcomePageViewController, didTapPageActionButtonIndex index: Int)
}

class WelcomePageViewController: UIPageViewController {

    weak var welcomeDelegate: WelcomePageViewControllerDelegate?

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return WelcomeViewControllerPage.allCases.map {
            instantieViewController(forPage: $0)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }

        welcomeDelegate?.welcomePageViewController(welcomePageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }

    // MARK: - Public

    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }

    // MARK: - Private

    fileprivate func scrollToViewController(viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController], direction: direction, animated: true, completion: { _ -> Void in
            self.notifyDelegateCurrentIndex()
        })
    }

    fileprivate func notifyDelegateCurrentIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            welcomeDelegate?.welcomePageViewController(welcomePageViewController: self, didUpdatePageIndex: index)
        }
    }

    fileprivate func instantieViewController(forPage page: WelcomeViewControllerPage) -> WelcomePageItemViewController {
        guard let pageItemViewController = UIStoryboard(name: Constants.StoryboardID.welcome, bundle: nil).instantiateViewController(withIdentifier: page.rawValue) as? WelcomePageItemViewController else {
            return WelcomePageItemViewController()
        }

        pageItemViewController.delegate = self
        return pageItemViewController
    }
}

extension WelcomePageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0,
            orderedViewControllers.count > previousIndex else { return nil }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1

        guard orderedViewControllers.count != nextIndex,
            orderedViewControllers.count > nextIndex else { return nil }

        return orderedViewControllers[nextIndex]
    }
}

extension WelcomePageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyDelegateCurrentIndex()
    }
}

extension WelcomePageViewController: WelcomePageItemViewControllerDelegate {

    func didTapActionButton(welcomePageItemViewController: WelcomePageItemViewController) {
        guard let index = orderedViewControllers.firstIndex(of: welcomePageItemViewController) else { return }

        welcomeDelegate?.welcomePageViewController(welcomePageViewController: self, didTapPageActionButtonIndex: index)
    }
}
