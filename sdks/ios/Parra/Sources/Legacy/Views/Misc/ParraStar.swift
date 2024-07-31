//
//  ParraStar.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

class ParraStar: UIView, ParraLegacyConfigurableView {
    // MARK: - Lifecycle

    required init(
        frame: CGRect,
        config: ParraCardViewConfig,
        isHighlighted: Bool = false,
        edgeInsets: UIEdgeInsets = UIEdgeInsets(
            top: 8.0,
            left: 8.0,
            bottom: 8.0,
            right: 8.0
        )
    ) {
        self.config = config
        self.isHighlighted = isHighlighted
        self.edgeInsets = edgeInsets

        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }

    var edgeInsets: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let insetRect = rect.inset(by: edgeInsets).integral
        let path = UIBezierPath()
        path.lineWidth = 4.0

        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        let radius: CGFloat = insetRect.width / 2.0

        let tipRadius: CGFloat = if isHighlighted {
            radius * 0.90
        } else {
            radius * 0.80
        }

        let innerRadius: CGFloat = if isHighlighted {
            radius * 0.43
        } else {
            radius * 0.38
        }

        var cangle: CGFloat = 18.0
        for i in 1 ... 10 {
            let rad: CGFloat = if i % 2 == 0 {
                tipRadius
            } else {
                innerRadius
            }

            let cc = CGPoint(
                x: center.x + rad * cos(cangle * CGFloat.pi / 180.0),
                y: center.y + rad * sin(cangle * CGFloat.pi / 180.0)
            )

            let p = CGPoint(
                x: cc.x + cos((cangle - 72) * CGFloat.pi / 180.0),
                y: cc.y + sin((cangle - 72) * CGFloat.pi / 180.0)
            )

            if i == 1 {
                path.move(to: p)
            } else {
                path.addLine(to: p)
            }

            cangle += 36.0
        }

        path.close()

        if isHighlighted {
            config.accessoryTintColor?.setFill()
            config.accessoryTintColor?.setStroke()
            path.stroke()
            path.fill()
        } else {
            config.accessoryDisabledTintColor?.setStroke()
            path.stroke()
        }
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        self.config = config
        backgroundColor = config.backgroundColor

        setNeedsDisplay()
    }

    // MARK: - Private

    private var config: ParraCardViewConfig
}
