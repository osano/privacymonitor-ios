//
//  ScoreTrendCircularView.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

class ScoreTrendCircularView: UIView {

    enum Metrics {
        static let backgroundCircleWidth: CGFloat = 6.0
        static let trendIconWidthScaleFactor: CGFloat = 163.0 / 63.0
    }

    fileprivate let backgroundCircleLayer = CAShapeLayer()
    fileprivate let trendCircleLayer = CAShapeLayer()
    fileprivate let previousScoreLayer = CAShapeLayer()

    @IBInspectable var circleLineWidth: CGFloat = ScoreTrendCircularView.Metrics.backgroundCircleWidth {
        didSet {
            backgroundCircleLayer.lineWidth = circleLineWidth
            trendCircleLayer.lineWidth = circleLineWidth
            previousScoreLayer.lineWidth = circleLineWidth + 1.0
        }
    }

    lazy var trendImageView: UIImageView = {
        let trendImageView = UIImageView()
        trendImageView.translatesAutoresizingMaskIntoConstraints = false
        trendImageView.contentMode = .scaleAspectFit
        return trendImageView
    }()

    private lazy var trendImageViewWidthConstraint: NSLayoutConstraint = {
        let trendImageViewWidthConstraint = trendImageView.widthAnchor.constraint(equalToConstant: 0.0)
        return trendImageViewWidthConstraint
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

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundCircleLayer.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)).cgPath
        trendImageViewWidthConstraint.constant = bounds.width / ScoreTrendCircularView.Metrics.trendIconWidthScaleFactor
    }

    // MARK: - Public

    func configureWithScore(_ score: Int, previousScore: Int? = 0, scoreColor: UIColor) {
        let minScore: CGFloat = 300.0
        let maxScore: CGFloat = 850.0
        let scorePercentage = (CGFloat(score) - minScore) / (maxScore - minScore)

        // Draw score indicator
        let minDegree: CGFloat = -90.0
        let maxDegree: CGFloat = 270.0
        let degreeFromScore = (scorePercentage * (maxDegree - minDegree)) + minDegree

        let startAngle = minDegree
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.size.height / 2.0

        trendCircleLayer.path = UIBezierPath(arcCenter: arcCenter,
                                             radius: radius,
                                             startAngle: startAngle.degreesToRadians,
                                             endAngle: degreeFromScore.degreesToRadians,
                                             clockwise: true).cgPath
        trendCircleLayer.strokeColor = scoreColor.cgColor

        // Draw previous score indicator
        guard let previousScore = previousScore, previousScore > 0, previousScore != score else { return }

        let previousScorePercentage = (CGFloat(previousScore) - minScore) / (maxScore - minScore)
        let degreeFromPreviousScore = (previousScorePercentage * (maxDegree - minDegree)) + minDegree
        let previousScoreThickness: CGFloat = 2.0

        previousScoreLayer.path = UIBezierPath(arcCenter: arcCenter,
                                               radius: radius,
                                               startAngle: (degreeFromPreviousScore - previousScoreThickness).degreesToRadians,
                                               endAngle: (degreeFromPreviousScore + previousScoreThickness).degreesToRadians,
                                               clockwise: true).cgPath
        previousScoreLayer.strokeColor = score > previousScore ? UIColor.white.cgColor : UIColor.trendDecliningColor().cgColor
    }

    // MARK: - Private

    func commonInit() {
        backgroundColor = .clear

        backgroundCircleLayer.strokeColor = UIColor.scoreTipCircleBackgroundColor().cgColor
        backgroundCircleLayer.lineWidth = circleLineWidth
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.contentsScale = UIScreen.main.scale
        backgroundCircleLayer.shouldRasterize = false

        trendCircleLayer.lineWidth = circleLineWidth
        trendCircleLayer.fillColor = UIColor.clear.cgColor
        trendCircleLayer.contentsScale = UIScreen.main.scale
        trendCircleLayer.shouldRasterize = false

        previousScoreLayer.lineWidth = circleLineWidth + 1.0
        previousScoreLayer.fillColor = UIColor.clear.cgColor
        previousScoreLayer.contentsScale = UIScreen.main.scale
        previousScoreLayer.shouldRasterize = false

        layer.addSublayer(backgroundCircleLayer)
        layer.addSublayer(trendCircleLayer)
        layer.addSublayer(previousScoreLayer)

        addSubview(trendImageView)

        let constraints = [
            trendImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            trendImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trendImageViewWidthConstraint
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
}
