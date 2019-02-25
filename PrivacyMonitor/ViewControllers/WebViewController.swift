//
//  WebViewController.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import CleanroomLogger
import PrivacyMonitorFramework
import UIKit
import WebKit

// swiftlint:disable:next type_body_length
class WebViewController: UIViewController {

    enum Metrics {
        static let navigationToolBarHeight: CGFloat = 54.0
        static let navigationToolBarFixedItemWidth: CGFloat = 20.0
    }

    fileprivate let privacyMonitor = PrivacyMonitor()
    fileprivate var viewModel: DomainViewModel?
    fileprivate var urlKeyValueObserver: NSKeyValueObservation?
    fileprivate var progressKeyValueObserver: NSKeyValueObservation?
    fileprivate var isLoadingKeyValueObserver: NSKeyValueObservation?
    fileprivate var toolTipTimer: Timer?

    lazy var webViewSearchView: WebViewSearchView = {
        let webViewSearchView = WebViewSearchView()
        webViewSearchView.translatesAutoresizingMaskIntoConstraints = false
        webViewSearchView.delegate = self
        return webViewSearchView
    }()

    lazy var webErrorView: WebErrorView = {
        let webErrorView = WebErrorView()
        webErrorView.translatesAutoresizingMaskIntoConstraints = false
        webErrorView.isHidden = true
        return webErrorView
    }()

    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    lazy var toolTipView: ToolTipView = {
        let toolTipView = ToolTipView()
        toolTipView.translatesAutoresizingMaskIntoConstraints = false
        toolTipView.alpha = 0.0
        toolTipView.delegate = self
        return toolTipView
    }()

    lazy var toolTipViewBottomConstraint: NSLayoutConstraint = {
        let toolTipViewBottomConstraint = toolTipView.bottomAnchor.constraint(equalTo: webViewSearchView.bottomAnchor)
        return toolTipViewBottomConstraint
    }()

    lazy var navigationToolBar: UIToolbar = {
        let navigationToolBar = UIToolbar()
        navigationToolBar.translatesAutoresizingMaskIntoConstraints = false
        navigationToolBar.isTranslucent = false
        navigationToolBar.tintColor = .black
        navigationToolBar.barTintColor = .white
        return navigationToolBar
    }()

    lazy var backButtonItem: UIBarButtonItem = {
        let backButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBarBackButton"), style: .done, target: self, action: #selector(backButtonTapped(sender:)))
        backButtonItem.isEnabled = false
        return backButtonItem
    }()

    lazy var forwardButtonItem: UIBarButtonItem = {
        let forwardButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBarForwardButton"), style: .done, target: self, action: #selector(forwardButtonTapped(sender:)))
        forwardButtonItem.isEnabled = false
        return forwardButtonItem
    }()

    lazy var favoritesButtonItem: UIBarButtonItem = {
        let favoritesButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBarFavoritesButton"), style: .done, target: self, action: #selector(favoritesButtonTapped(sender:)))
        return favoritesButtonItem
    }()

    lazy var actionButtonItem: UIBarButtonItem = {
        let actionButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBarActionButton"), style: .done, target: self, action: #selector(actionButtonTapped(sender:)))
        return actionButtonItem
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        view.addSubview(webErrorView)
        view.addSubview(toolTipView)
        view.addSubview(webViewSearchView)
        view.addSubview(navigationToolBar)

        let constraints = [
            toolTipView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolTipView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolTipViewBottomConstraint,
            toolTipView.heightAnchor.constraint(equalToConstant: ToolTipView.Metrics.height),

            webViewSearchView.topAnchor.constraint(equalTo: view.topAnchor),
            webViewSearchView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webViewSearchView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webViewSearchView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            webView.topAnchor.constraint(equalTo: webViewSearchView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            webErrorView.topAnchor.constraint(equalTo: webView.topAnchor),
            webErrorView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            webErrorView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            webErrorView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),

            navigationToolBar.topAnchor.constraint(equalTo: webView.bottomAnchor),
            navigationToolBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationToolBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            navigationToolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            navigationToolBar.heightAnchor.constraint(equalToConstant: WebViewController.Metrics.navigationToolBarHeight)
        ]

        NSLayoutConstraint.activate(constraints)

        setupNavigationBarItems()

        configureWebViewKeyValueObservers()

        if let url = URL(string: Constants.App.initialURL) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit {
        urlKeyValueObserver = nil
        progressKeyValueObserver = nil
        isLoadingKeyValueObserver = nil

        toolTipTimer?.invalidate()
        toolTipTimer = nil
    }

    // MARK: - Private

    fileprivate func setupNavigationBarItems() {
        let initialFixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        initialFixedItem.width = WebViewController.Metrics.navigationToolBarFixedItemWidth

        let lastFixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        lastFixedItem.width = WebViewController.Metrics.navigationToolBarFixedItemWidth

        let items = [
            initialFixedItem,
            backButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            forwardButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            favoritesButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            actionButtonItem,
            lastFixedItem
        ]

        navigationToolBar.items = items
    }

    fileprivate func configureWebViewKeyValueObservers() {
        // KVO (WKWebView url)
        urlKeyValueObserver = webView.observe(\.url, options: [.old, .new]) { [weak self] _, change in
            guard let strongSelf = self,
                let urlString = change.newValue??.absoluteString else { return }

            strongSelf.webViewSearchView.text = urlString

            // Hide score tooltip if needed
            strongSelf.showScoreTipView(false)

            if let urlString = change.oldValue??.absoluteString,
                urlString == Constants.App.blankPageURL {
                strongSelf.webErrorView.isHidden = true
            }
        }

        // KVO (WKWebView estimatedProgress)
        progressKeyValueObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            self?.webViewSearchView.updateProgressBar(Float(change.newValue ?? 0.0))
        }

        // KVO (WKWebView isLoading)
        isLoadingKeyValueObserver = webView.observe(\.isLoading, options: [.new]) { [weak self] _, _ in
            guard let strongSelf = self else { return }

            strongSelf.backButtonItem.isEnabled = strongSelf.webView.canGoBack
            strongSelf.forwardButtonItem.isEnabled = strongSelf.webView.canGoForward
        }
    }

    func showScoreTipView(_ show: Bool, errorMessage: String? = nil) {
        guard !(show && toolTipView.alpha == 1.0) && !(!show && toolTipView.alpha == 0.0) else {
            return
        }

        toolTipViewBottomConstraint.constant = show ? ToolTipView.Metrics.height : 0.0

        // Invalidate autohide timer
        toolTipTimer?.invalidate()
        toolTipTimer = nil

        if show {
            if let errorMessage = errorMessage {
                toolTipView.style = .error(errorMessage)
            }
            else {
                toolTipView.style = .score
            }

            toolTipView.alpha = 1.0
            toolTipTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                                target: self,
                                                selector: #selector(autocloseToolTip(_:)),
                                                userInfo: nil,
                                                repeats: false)
        }

        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }, completion: { completed in
            if completed, !show {
                self.toolTipView.alpha = 0.0
            }
        })
    }

    fileprivate func requestScore(forURL url: URL) {
        // Start animating the get score button
        webViewSearchView.startLoadingScoreButton()

        privacyMonitor.requestDomainScore(withURL: url) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case let .success(domain):
                // Update UI
                strongSelf.showScoreTipView(true)
                strongSelf.webViewSearchView.stopLoadingScoreButton()

                let viewModel = DomainViewModel(domain: domain)
                strongSelf.viewModel = viewModel
                strongSelf.toolTipView.viewModel = viewModel

            case let .failure(error):
                strongSelf.webViewSearchView.stopLoadingScoreButton()
                strongSelf.handleRequestScoreError(error)
            }
        }
    }

    fileprivate func requestScoreAnalysis(forURL url: URL) {
        webViewSearchView.startLoadingScoreButton()

        privacyMonitor.requestScoreAnalysis(withURL: url) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.webViewSearchView.stopLoadingScoreButton()

            switch result {
            case let .success(success):
                if success {
                    strongSelf.toolTipView.messageLabel.text = Constants.App.scoreAnalysisSuccessText
                    strongSelf.toolTipView.enableActionButton(false)
                }
            case .failure:
                strongSelf.toolTipView.messageLabel.text = Constants.ErrorMessages.unknown
            }
        }
    }

    fileprivate func handleRequestScoreError(_ error: PrivacyMonitorError) {
        var errorMessage = error.localizedDescription
        switch error {
        case .domainDoesNotExist:
            errorMessage = Constants.ErrorMessages.domainDoesNotExist
        default:
            errorMessage = Constants.ErrorMessages.unknown
        }

        showScoreTipView(true, errorMessage: errorMessage)

        Log.warning?.message(error.localizedDescription)
    }

    @objc
    fileprivate func autocloseToolTip(_ sender: AnyObject) {
        showScoreTipView(false)
    }

    // MARK: - User Interaction

    @objc
    fileprivate func backButtonTapped(sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc
    fileprivate func forwardButtonTapped(sender: UIBarButtonItem) {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc
    fileprivate func favoritesButtonTapped(sender: UIBarButtonItem) {
        let favoritesViewController = FavoritesViewController()
        favoritesViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: favoritesViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }

    @objc
    fileprivate func actionButtonTapped(sender: UIBarButtonItem) {
        guard let url = webView.url else { return }

        let activity = AddToFavoritesActivity()
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [activity])

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }

        present(activityViewController, animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }

        privacyMonitor.registerDomainVisit(withURL: url) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case let .success(domain):
                // Update UI
                strongSelf.showScoreTipView(true)
                strongSelf.webViewSearchView.stopLoadingScoreButton()

                let viewModel = DomainViewModel(domain: domain)
                strongSelf.viewModel = viewModel
                strongSelf.toolTipView.viewModel = viewModel

            default:
                break
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Log.error?.message(error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Log.error?.message(error.localizedDescription)

        handleWebViewError(error)
    }

    fileprivate func handleWebViewError(_ error: Error) {
        guard let url = URL(string: Constants.App.blankPageURL) else { return }

        webView.load(URLRequest(url: url))

        webViewSearchView.text = nil

        webErrorView.configure(withMessage: Constants.ErrorMessages.cannotFindHost)
        webErrorView.isHidden = false
    }
}

// MARK: - WebViewSearchViewDelegate

extension WebViewController: WebViewSearchViewDelegate {

    func scoreButtonDidTap(_ button: UIButton) {
        guard let url = webView.url else { return }

        requestScore(forURL: url)
    }

    func keyboardReturnDoneButtonDidTap(_ text: String) {
        guard text.isValidURL, let url = text.asHTTPURL else {
            if let encodedUrl = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                let url = URL(string: Constants.App.redirectURL + encodedUrl) {
                webView.load(URLRequest(url: url))
            }
            return
        }

        _ = webViewSearchView.resignFirstResponder()

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}

// MARK: - ToolTipViewDelegate

extension WebViewController: ToolTipViewDelegate {

    func closeButtonDidTap(_ button: UIButton) {
        showScoreTipView(false)
    }

    func actionButtonDidTap(_ button: UIButton) {
        guard let url = webView.url else { return }

        requestScoreAnalysis(forURL: url)
    }
}

extension WebViewController: FavoritesViewControllerDelegate {

    func favoriteUrlDidTap(_ urlString: String) {
        guard urlString.isValidURL, let url = urlString.asHTTPURL else { return }

        _ = webViewSearchView.resignFirstResponder()

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}
