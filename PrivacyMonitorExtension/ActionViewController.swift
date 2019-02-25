//
//  ActionViewController.swift
//  PrivacyMonitorExtension
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import CleanroomLogger
import MobileCoreServices
import PrivacyMonitorFramework
import UIKit

class ActionViewController: UIViewController {

    @IBOutlet fileprivate weak var domainNameLabel: UILabel!
    @IBOutlet fileprivate weak var scoreTrendCircularView: ScoreTrendCircularView!
    @IBOutlet fileprivate weak var scoreLabel: UILabel!
    @IBOutlet fileprivate weak var scoreDescriptionLabel: UILabel!
    @IBOutlet fileprivate weak var trendDescriptionLabel: UILabel!
    @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var messageLabel: UILabel!
    @IBOutlet fileprivate weak var actionButton: UIButton!

    fileprivate var url: URL?

    fileprivate let privacyMonitor = PrivacyMonitor()
    fileprivate var viewModel: DomainViewModel? {
        didSet {
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }

    // MARK: - Lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        actionButton.layer.borderColor = actionButton.tintColor.cgColor

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else { return }

        let propertyList = String(kUTTypeURL)
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil) { item, _ in
                guard let url = item as? URL else { return }

                self.url = url

                DispatchQueue.main.async {
                    self.domainNameLabel.text = url.rootDomain
                    self.activityIndicatorView.startAnimating()
                }

                self.privacyMonitor.requestDomainScore(withURL: url, completion: { [weak self] result in
                    switch result {
                    case let .success(domain):
                        self?.viewModel = DomainViewModel(domain: domain)
                    case let .failure(error):
                        Log.warning?.message(error.localizedDescription)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self?.activityIndicatorView.stopAnimating()
                            self?.handleError(error)
                        }
                    }
                })
            }
        }
    }

    // MARK: - Private

    fileprivate func commonInit() {
        Log.enable()
    }

    fileprivate func updateUI() {
        activityIndicatorView.stopAnimating()
        domainNameLabel.text = viewModel?.rootDomain
        scoreTrendCircularView.isHidden = false
        scoreTrendCircularView.trendImageView.image = viewModel?.trendImage
        scoreTrendCircularView.configureWithScore(viewModel?.score ?? 0, previousScore: viewModel?.previousScore, scoreColor: viewModel?.scoreColor ?? .trendNoChangeColor())
        scoreLabel.text = viewModel?.scoreNumberDescription
        scoreDescriptionLabel.text = viewModel?.scoreDescription
        scoreDescriptionLabel.textColor = viewModel?.scoreColor
        trendDescriptionLabel.attributedText = viewModel?.attributtedTrendString()
    }

    fileprivate func handleError(_ error: PrivacyMonitorError) {
        var errorMessage = error.localizedDescription
        switch error {
        case .domainDoesNotExist:
            errorMessage = Constants.ErrorMessages.domainDoesNotExist
        default:
            errorMessage = Constants.ErrorMessages.unknown
        }

        actionButton.isHidden = false
        messageLabel.isHidden = false

        messageLabel.text = errorMessage

        Log.warning?.message(error.localizedDescription)
    }

    fileprivate func closeExtension() {
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

    func enableActionButton(_ enable: Bool) {
        actionButton.isEnabled = enable
        actionButton.layer.borderColor = enable ? actionButton.tintColor.cgColor : UIColor.lightGray.cgColor
    }

    // MARK: - User Interaction

    @IBAction fileprivate func done() {
        closeExtension()
    }

    @IBAction fileprivate func actionButtonTapped(_ sender: Any) {
        guard let url = url else { return }

        activityIndicatorView.startAnimating()

        privacyMonitor.requestScoreAnalysis(withURL: url) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.activityIndicatorView.stopAnimating()

            switch result {
            case let .success(success):
                if success {
                    strongSelf.messageLabel.text = Constants.App.scoreAnalysisSuccessText
                    strongSelf.enableActionButton(false)
                }
            case .failure:
                strongSelf.messageLabel.text = Constants.ErrorMessages.unknown
            }
        }
    }
}
