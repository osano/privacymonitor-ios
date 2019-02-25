//
//  ToolTipView.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

protocol ToolTipViewDelegate: AnyObject {
    func closeButtonDidTap(_ button: UIButton)
    func actionButtonDidTap(_ button: UIButton)
}

enum ToolTipViewStyle {
    case score
    case error(String)
}

class ToolTipView: UIView {

    struct Metrics {
        static let height: CGFloat = 85.0
        static let layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        static let shadowOpacity: Float = 0.1
        static let shadowOffset = CGSize(width: 0.0, height: 2.0)
        static let contentViewLeadingMargin: CGFloat = 10.0
        static let contentViewTrailingMargin: CGFloat = 10.0
        static let scoreTrendCircularViewSize = CGSize(width: 55.0, height: 55.0)
        static let trendLabelLeadingMargin: CGFloat = 6.0
        static let scoreStackViewTrailingMargin: CGFloat = 20.0
        static let closeButtonWidth: CGFloat = 45.0
        static let messageLabelTrailingMargin: CGFloat = 12.0
        static let actionButtonTrailingMargin: CGFloat = 5.0
        static let actionButtonSize = CGSize(width: 85.0, height: 32.0)
        static let actionButtonCornerRadius: CGFloat = 8.0
    }

    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    lazy var scoreTrendCircularView: ScoreTrendCircularView = {
        let scoreTrendCircularView = ScoreTrendCircularView()
        scoreTrendCircularView.translatesAutoresizingMaskIntoConstraints = false
        return scoreTrendCircularView
    }()

    lazy var scoreStackView: UIStackView = {
        let scoreStackView = UIStackView()
        scoreStackView.translatesAutoresizingMaskIntoConstraints = false
        scoreStackView.axis = .vertical
        scoreStackView.spacing = 2.0
        return scoreStackView
    }()

    lazy var scoreLabel: UILabel = {
        let scoreLabel = UILabel()
        scoreLabel.font = .privacyMonitorBoldFont(ofSize: 20.0)
        scoreLabel.minimumScaleFactor = 0.7
        scoreLabel.adjustsFontSizeToFitWidth = true
        return scoreLabel
    }()

    lazy var scoreDescriptionLabel: UILabel = {
        let scoreDescriptionLabel = UILabel()
        scoreDescriptionLabel.font = .privacyMonitorRegularFont(ofSize: 15.0)
        scoreDescriptionLabel.textColor = .blueTextColor()
        return scoreDescriptionLabel
    }()

    lazy var trendLabel: UILabel = {
        let trendLabel = UILabel()
        trendLabel.translatesAutoresizingMaskIntoConstraints = false
        trendLabel.numberOfLines = 0
        trendLabel.textAlignment = .center
        return trendLabel
    }()

    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.isHidden = true
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = .privacyMonitorRegularFont(ofSize: 15.0)
        messageLabel.textColor = .blueTextColor()
        messageLabel.minimumScaleFactor = 0.7
        messageLabel.adjustsFontSizeToFitWidth = true
        return messageLabel
    }()

    lazy var actionButton: UIButton = {
        let actionButton = UIButton(type: .system)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.isHidden = true
        actionButton.tintColor = .secondaryTintColor()
        actionButton.setTitle("Request Score", for: .normal)
        actionButton.titleLabel?.font = UIFont.privacyMonitorRegularFont(ofSize: 12.0)
        actionButton.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
        actionButton.layer.borderColor = actionButton.tintColor.cgColor
        actionButton.layer.borderWidth = 1.0
        actionButton.layer.cornerRadius = ToolTipView.Metrics.actionButtonCornerRadius
        return actionButton
    }()

    lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(#imageLiteral(resourceName: "ScoreCloseButton"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)
        return closeButton
    }()

    weak var delegate: ToolTipViewDelegate?
    var style: ToolTipViewStyle = .score {
        didSet {
            updateStyle()
        }
    }

    var viewModel: DomainViewModel? {
        didSet {
            configureUI()
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Private

    fileprivate func commonInit() {
        backgroundColor = .toolTipBackgroundColor()
        layoutMargins = ToolTipView.Metrics.layoutMargins

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = ToolTipView.Metrics.shadowOpacity
        layer.shadowOffset = ToolTipView.Metrics.shadowOffset

        addSubview(contentView)
        addSubview(closeButton)
        addSubview(messageLabel)
        addSubview(actionButton)

        contentView.addSubview(scoreTrendCircularView)
        contentView.addSubview(scoreStackView)
        contentView.addSubview(trendLabel)

        scoreStackView.addArrangedSubview(scoreLabel)
        scoreStackView.addArrangedSubview(scoreDescriptionLabel)

        let constraints = [
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: ToolTipView.Metrics.contentViewLeadingMargin),
            contentView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -ToolTipView.Metrics.contentViewTrailingMargin),

            closeButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: ToolTipView.Metrics.closeButtonWidth),
            closeButton.heightAnchor.constraint(equalToConstant: ToolTipView.Metrics.closeButtonWidth),

            scoreTrendCircularView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scoreTrendCircularView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scoreTrendCircularView.widthAnchor.constraint(equalToConstant: ToolTipView.Metrics.scoreTrendCircularViewSize.width),
            scoreTrendCircularView.heightAnchor.constraint(equalToConstant: ToolTipView.Metrics.scoreTrendCircularViewSize.height),

            scoreStackView.leadingAnchor.constraint(equalTo: scoreTrendCircularView.trailingAnchor, constant: ToolTipView.Metrics.scoreStackViewTrailingMargin),
            scoreStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            trendLabel.leadingAnchor.constraint(equalTo: scoreStackView.trailingAnchor, constant: ToolTipView.Metrics.trendLabelLeadingMargin),
            trendLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trendLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -ToolTipView.Metrics.messageLabelTrailingMargin),

            actionButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -ToolTipView.Metrics.actionButtonTrailingMargin),
            actionButton.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: ToolTipView.Metrics.actionButtonSize.width),
            actionButton.heightAnchor.constraint(equalToConstant: ToolTipView.Metrics.actionButtonSize.height)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    fileprivate func configureUI() {
        guard let viewModel = viewModel else { return }

        scoreTrendCircularView.trendImageView.image = viewModel.trendImage
        scoreTrendCircularView.configureWithScore(viewModel.score, previousScore: viewModel.previousScore, scoreColor: viewModel.scoreColor)
        scoreLabel.text = viewModel.scoreNumberDescription
        scoreDescriptionLabel.text = viewModel.scoreDescription
        scoreDescriptionLabel.textColor = viewModel.scoreColor
        trendLabel.attributedText = viewModel.attributtedTrendString(format: .newLine)
    }

    fileprivate func updateStyle() {
        switch style {
        case .score:
            contentView.isHidden = false
            messageLabel.isHidden = true
            actionButton.isHidden = true
        case let .error(message):
            contentView.isHidden = true
            messageLabel.isHidden = false
            actionButton.isHidden = false

            messageLabel.text = message
            enableActionButton(true)
        }
    }

    // MARK: - Public

    func enableActionButton(_ enable: Bool) {
        actionButton.isEnabled = enable
        actionButton.layer.borderColor = enable ? actionButton.tintColor.cgColor : UIColor.lightGray.cgColor
    }

    // MARK: - User Interaction

    @objc
    func closeButtonTapped(sender: UIButton) {
        delegate?.closeButtonDidTap(sender)
    }

    @objc
    fileprivate func actionButtonTapped(sender: UIButton) {
        delegate?.actionButtonDidTap(sender)
    }
}
