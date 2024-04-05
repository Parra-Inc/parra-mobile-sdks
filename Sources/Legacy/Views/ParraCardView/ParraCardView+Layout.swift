//
//  ParraCardView+Layout.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit

extension ParraCardView {
    enum LayoutConstants {
        static let navigationPadding: CGFloat = 5
        static let contentPadding: CGFloat = 12
    }

    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        removeConstraints(constraintsOnSuperView)
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview == nil {
            return
        }
        removeConstraints(constraintsOnSuperView)

        let widthConstraint = widthAnchor.constraint(
            greaterThanOrEqualToConstant: Dimensions.minWidth
        )
        widthConstraint.priority = .init(999)

        let aspectRatioConstraint = heightAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: Dimensions.minHeight / Dimensions.minWidth
        )
        aspectRatioConstraint.priority = .required

        constraintsOnSuperView = [
            widthConstraint,
            aspectRatioConstraint
        ]

        NSLayoutConstraint.activate(constraintsOnSuperView)
    }

    func configureSubviews(config: ParraCardViewConfig) {
        configureContentView()
        configureNavigationStack()

        containerLeadingConstraint = containerView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: config.contentInsets.left
        )
        containerTrailingConstraint = containerView.trailingAnchor.constraint(
            equalTo: trailingAnchor,
            constant: -config.contentInsets.right
        )
        containerTopConstraint = containerView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: config.contentInsets.top
        )
        containerBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -config.contentInsets.bottom
        )

        NSLayoutConstraint.activate(constraintsOncontainerView)

        applyConfig(config)

        transitionToNextCard(animated: false)
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        containerView.backgroundColor = config.backgroundColor
        containerView.layer.cornerRadius = config.cornerRadius

        poweredByButton.setTitleColor(
            config.backgroundColor.isLight()
                ? .black.withAlphaComponent(0.1)
                : .white.withAlphaComponent(0.2),
            for: .normal
        )

        layer.shadowColor = config.shadow.color.cgColor
        layer.shadowOpacity = Float(config.shadow.opacity)
        layer.shadowRadius = config.shadow.radius
        layer.shadowOffset = config.shadow.offset
        layer.bounds = bounds
        layer.position = center

        var needsLayout = false

        if config.contentInsets.left != containerLeadingConstraint.constant {
            containerLeadingConstraint.constant = config.contentInsets.left
            needsLayout = true
        }

        if -config.contentInsets.right != containerTrailingConstraint.constant {
            containerTrailingConstraint.constant = -config.contentInsets.right
            needsLayout = true
        }

        if config.contentInsets.top != containerTopConstraint.constant {
            containerTopConstraint.constant = config.contentInsets.top
            needsLayout = true
        }

        if -config.contentInsets.bottom != containerBottomConstraint.constant {
            containerBottomConstraint.constant = -config.contentInsets.bottom
            needsLayout = true
        }

        if needsLayout {
            layoutIfNeeded()
        }

        if let currentCardInfo {
            currentCardInfo.cardItemView.config = config
        }
    }

    private func configureContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )
        contentView.setContentHuggingPriority(.init(0), for: .vertical)
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = true
        contentView.accessibilityIdentifier = "ParraFeedbackContentView"

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(
                equalTo: navigationStack.bottomAnchor,
                constant: LayoutConstants.navigationPadding
            ),
            contentView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 0
            ),
            contentView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: 0
            ),
            contentView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: 0
            )
        ])
    }
}
