//
//  ParraBorderedRatingControl.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal protocol ParraBorderedRatingControlDelegate: AnyObject {
    func parraBorderedRatingControl(_ control: ParraBorderedRatingControl,
                                    didSelectOption option: RatingQuestionOption)

    func parraBorderedRatingControl(_ control: ParraBorderedRatingControl,
                                    didConfirmOption option: RatingQuestionOption)
}

internal class ParraBorderedRatingControl: UIControl, ParraLegacyConfigurableView {
    internal weak var delegate: ParraBorderedRatingControlDelegate?

    private let config: ParraCardViewConfig
    private let labelStack = UIStackView(frame: .zero)
    private var highlightedOption: RatingQuestionOption?

    private var optionLabelMap = [UILabel: RatingQuestionOption]()

    required init(options: [RatingQuestionOption],
                  config: ParraCardViewConfig) {
        self.config = config

        assert(options.count <= 10, "The layout of this control was never considered with this many options")

        super.init(frame: .zero)

        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderWidth = 1.5

        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.isUserInteractionEnabled = false
        labelStack.axis = .horizontal
        labelStack.spacing = 0
        labelStack.alignment = .fill
        labelStack.distribution = .fillEqually

        for option in options {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = false
            label.textAlignment = .center
            label.text = option.title
            label.layer.borderWidth = 0.5

            optionLabelMap[label] = option

            labelStack.addArrangedSubview(label)
        }

        addSubview(labelStack)

        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            labelStack.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            labelStack.topAnchor.constraint(
                equalTo: topAnchor
            ),
            labelStack.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
        ])

        applyConfig(config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        respondToTouchChange(touch: touch, with: event)

        return super.beginTracking(touch, with: event)
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        respondToTouchChange(touch: touch, with: event)

        return super.continueTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch {
            respondToTouchChange(touch: touch, with: event)
        }

        return super.endTracking(touch, with: event)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: labelStack.intrinsicContentSize.width,
            height: 54
        )
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        layer.borderColor = config.accessoryDisabledTintColor?.cgColor

        for subview in labelStack.arrangedSubviews {
            guard let label = subview as? UILabel else {
                continue
            }

            label.textColor = config.title.color
            label.font = config.title.font
            label.layer.borderColor = config.accessoryDisabledTintColor?.cgColor

            let option = optionLabelMap[label]

            // Setting the background color on the labels layer is necessary to support animation
            label.layer.backgroundColor = option == highlightedOption
                ? config.accessoryTintColor?.cgColor : UIColor.clear.cgColor
        }
    }

    private func respondToTouchChange(touch: UITouch, with event: UIEvent?) {
        guard let label = labelBelow(touch: touch, with: event) else {
            return
        }

        guard let nextHightedOption = optionLabelMap[label] else {
            return
        }

        if nextHightedOption == highlightedOption {
            if touch.phase == .ended {
                delegate?.parraBorderedRatingControl(self,
                                                     didConfirmOption: nextHightedOption)
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

            strongSelf.delegate?.parraBorderedRatingControl(strongSelf,
                                                            didSelectOption: nextHightedOption)

        }
    }

    private func labelBelow(touch: UITouch, with event: UIEvent?) -> UILabel? {
        let touchLocation = labelStack.convert(touch.location(in: self), from: self)

        for subview in labelStack.arrangedSubviews {
            guard let label = subview as? UILabel else {
                continue
            }

            if label.frame.contains(touchLocation) {
                return label
            }
        }

        return nil
    }
}
