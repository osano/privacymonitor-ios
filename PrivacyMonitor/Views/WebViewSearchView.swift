//
//  WebViewSearchView.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import UIKit

protocol WebViewSearchViewDelegate: AnyObject {
    func scoreButtonDidTap(_ button: UIButton)
    func keyboardReturnDoneButtonDidTap(_ text: String)
}

private class TextField: UITextField {
    let inset = WebViewSearchView.Metrics.textFieldInset

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        var separatorFrame = bounds
        separatorFrame.size.height = 1.0
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 0.0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return editingTextFieldRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 0.0)
    }

    private func editingTextFieldRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.insetBy(dx: inset, dy: 0.0)
        rect.size.width -= inset
        return rect
    }
}

class WebViewSearchView: UIView {

    weak var delegate: WebViewSearchViewDelegate?

    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    struct Metrics {
        static let layoutMargins = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 12.0, right: 10.0)
        static let textFieldInset: CGFloat = 15.0
        static let textFieldHeight: CGFloat = 36.0
        static let textFieldCornerRadius: CGFloat = 18.0
        static let scoreButtonLeadingConstant: CGFloat = 10.0
        static let scoreButtonWidth: CGFloat = 40.0
        static let bottomBorderViewHeight: CGFloat = 1.0
    }

    fileprivate lazy var textField: TextField = {
        let textField = TextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = UIColor.searchTextFieldBackgroundColor()
        textField.font = UIFont.privacyMonitorRegularFont(ofSize: 16.0)
        textField.textColor = UIColor.primaryTextColor()
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.keyboardType = .URL
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Enter a website URL:"
        textField.layer.cornerRadius = WebViewSearchView.Metrics.textFieldCornerRadius
        return textField
    }()

    fileprivate lazy var scoreButton: UIButton = {
        let scoreButton = UIButton(type: .custom)
        scoreButton.translatesAutoresizingMaskIntoConstraints = false
        scoreButton.setImage(#imageLiteral(resourceName: "SearchActionButton"), for: .normal)
        scoreButton.addTarget(self, action: #selector(scoreButtonTapped(sender:)), for: .touchUpInside)
        return scoreButton
    }()

    fileprivate lazy var scoreActivityIndicatorView: UIActivityIndicatorView = {
        let scoreActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        scoreActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        scoreActivityIndicatorView.hidesWhenStopped = true
        return scoreActivityIndicatorView
    }()

    fileprivate lazy var bottomBorderView: UIView = {
        let bottomBorderView = UIView()
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.backgroundColor = .searchViewBorderColor()
        return bottomBorderView
    }()

    fileprivate lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .secondaryTintColor()
        progressView.trackTintColor = .searchViewBorderColor()
        progressView.alpha = 0.0
        return progressView
    }()

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
        backgroundColor = .white

        layoutMargins = WebViewSearchView.Metrics.layoutMargins

        addSubview(scoreButton)
        addSubview(scoreActivityIndicatorView)
        addSubview(textField)
        addSubview(bottomBorderView)
        addSubview(progressView)

        let constraints = [
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: WebViewSearchView.Metrics.layoutMargins.top),
            textField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textField.heightAnchor.constraint(equalToConstant: WebViewSearchView.Metrics.textFieldHeight),
            textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            scoreButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            scoreButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            scoreButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: WebViewSearchView.Metrics.scoreButtonLeadingConstant),
            scoreButton.widthAnchor.constraint(equalToConstant: WebViewSearchView.Metrics.scoreButtonWidth),
            scoreButton.heightAnchor.constraint(equalToConstant: WebViewSearchView.Metrics.scoreButtonWidth),

            scoreActivityIndicatorView.centerXAnchor.constraint(equalTo: scoreButton.centerXAnchor),
            scoreActivityIndicatorView.centerYAnchor.constraint(equalTo: scoreButton.centerYAnchor),

            bottomBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: WebViewSearchView.Metrics.bottomBorderViewHeight),

            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Public

    func updateProgressBar(_ progress: Float) {
        if progress == 1.0 {
            progressView.setProgress(progress, animated: true)
            UIView.animate(withDuration: 1.5, animations: {
                self.progressView.alpha = 0.0
            }, completion: { finished in
                if finished {
                    self.progressView.setProgress(0.0, animated: false)
                }
            })
        }
        else {
            if progressView.alpha < 1.0 {
                progressView.alpha = 1.0
            }
            progressView.setProgress(progress, animated: (progress > progressView.progress) && true)
        }
    }

    func startLoadingScoreButton() {
        scoreButton.isHidden = true
        scoreActivityIndicatorView.startAnimating()
    }

    func stopLoadingScoreButton() {
        scoreActivityIndicatorView.stopAnimating()
        scoreButton.isHidden = false
    }

    // MARK: - User Interaction

    @objc
    fileprivate func scoreButtonTapped(sender: UIButton) {
        delegate?.scoreButtonDidTap(sender)
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension WebViewSearchView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }

        delegate?.keyboardReturnDoneButtonDidTap(text)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
