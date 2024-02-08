//
//  ParraStarControl.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ParraStarControlDelegate: AnyObject {
    func parraStarControl(
        _ control: ParraStarControl,
        didSelectStarCount count: Int
    )

    func parraStarControl(
        _ control: ParraStarControl,
        didConfirmStarCount count: Int
    )
}

class ParraStarControl: UIControl, ParraLegacyConfigurableView {
    // MARK: Lifecycle

    required init(
        starCount: Int,
        config: ParraCardViewConfig
    ) {
        self.config = config

        assert(starCount > 1)
        assert(starCount <= 5)

        super.init(frame: .zero)

        starStack.translatesAutoresizingMaskIntoConstraints = false
        starStack.isUserInteractionEnabled = false
        starStack.axis = .horizontal
        starStack.spacing = 0
        starStack.alignment = .fill
        starStack.distribution = .fillEqually

        for num in 1 ... starCount {
            let star = ParraStar(frame: .zero, config: config)
            star.translatesAutoresizingMaskIntoConstraints = false
            star.isUserInteractionEnabled = false

            optionStarMap[star] = num

            starStack.addArrangedSubview(star)
        }

        addSubview(starStack)

        starStack.activateEdgeConstraints(to: self)

        applyConfig(config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    weak var delegate: ParraStarControlDelegate?

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: starStack.intrinsicContentSize.width,
            height: 60
        )
    }

    override func beginTracking(
        _ touch: UITouch,
        with event: UIEvent?
    ) -> Bool {
        respondToTouchChange(touch: touch, with: event)

        return super.beginTracking(touch, with: event)
    }

    override func continueTracking(
        _ touch: UITouch,
        with event: UIEvent?
    ) -> Bool {
        respondToTouchChange(touch: touch, with: event)

        return super.continueTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch {
            respondToTouchChange(touch: touch, with: event)
        }

        return super.endTracking(touch, with: event)
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        for (index, star) in stars.enumerated() {
            star.isHighlighted = index < highlightedOption
            star.applyConfig(config)
        }
    }

    // MARK: Private

    private let config: ParraCardViewConfig
    private let starStack = UIStackView(frame: .zero)
    private var highlightedOption: Int = 0

    private var optionStarMap = [ParraStar: Int]()

    private var stars: [ParraStar] {
        return starStack.arrangedSubviews.compactMap { view in
            return view as? ParraStar
        }
    }

    private func respondToTouchChange(touch: UITouch, with event: UIEvent?) {
        guard let star = starBelow(touch: touch, with: event) else {
            return
        }

        guard let nextHightedOption = optionStarMap[star] else {
            return
        }

        if nextHightedOption == highlightedOption {
            if touch.phase == .ended {
                delegate?.parraStarControl(
                    self,
                    didConfirmStarCount: nextHightedOption
                )
            }

            return
        }

        highlightedOption = nextHightedOption

        UIView.animate(
            withDuration: 0.15,
            delay: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) { [self] in
            applyConfig(config)
        } completion: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.parraStarControl(
                strongSelf,
                didSelectStarCount: nextHightedOption
            )
        }
    }

    private func starBelow(touch: UITouch, with event: UIEvent?) -> ParraStar? {
        let touchLocation = starStack.convert(
            touch.location(in: self),
            from: self
        )

        for star in stars {
            if star.frame.contains(touchLocation) {
                return star
            }
        }

        return nil
    }
}
