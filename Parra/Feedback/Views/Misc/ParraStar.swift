//
//  ParraStar.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal class ParraStar: UIView, ParraLegacyConfigurableView {
    private var config: ParraCardViewConfig

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let insetRect = rect.inset(by: edgeInsets).integral
        let path = UIBezierPath()
        path.lineWidth = 4
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = insetRect.width / 2
        let tipRadius = isHighlighted ? radius * 0.90 : radius * 0.80
        let innerRadius = isHighlighted ? radius * 0.43 : radius * 0.38

        var cangle: CGFloat = 18
        for i in 1...10 {
            let rad = i % 2 == 0 ? tipRadius : innerRadius
            let cc = CGPoint(
                x: center.x + rad * cos(cangle * .pi / 180),
                y: center.y + rad * sin(cangle * .pi / 180)
            )

            let p = CGPoint(
                x: cc.x + cos((cangle - 72) * .pi / 180),
                y: cc.y + sin((cangle - 72) * .pi / 180)
            )

            if i == 1 {
                path.move(to: p)
            } else {
                path.addLine(to: p)
            }

            cangle += 36
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
}
