//
//  ParraCardView+Layout.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit
import ParraCore

extension ParraCardView {
    enum LayoutConstants {
        static let navigationPadding: CGFloat = 5
        static let contentPadding: CGFloat = 12
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        removeConstraints(constraintsOnSuperView)
    }
    
    public override func didMoveToSuperview() {
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
    
    internal func configureSubviews(config: ParraCardViewConfig) {        
        configureContentView()
        configurePoweredByParraButton()

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
    
    internal func applyConfig(_ config: ParraCardViewConfig) {
        containerView.backgroundColor = config.backgroundColor
        containerView.layer.cornerRadius = config.cornerRadius
        
        poweredByButton.setTitleColor(config.backgroundColor.isLight()
                                      ? .black.withAlphaComponent(0.1)
                                      : .white.withAlphaComponent(0.2),
                                      for: .normal)

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
        
        if let currentCardInfo = currentCardInfo {
            currentCardInfo.cardItemView.config = config
        }
    }
    
    private func configureContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.setContentHuggingPriority(.init(0), for: .vertical)
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = true
        contentView.accessibilityIdentifier = "ParraFeedbackContentView"

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(
                equalTo: poweredByContainer.bottomAnchor,
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
    
    private func configurePoweredByParraButton() {
        poweredByContainer.translatesAutoresizingMaskIntoConstraints = false
        poweredByContainer.accessibilityIdentifier = "PoweredByParraContainer"
        poweredByContainer.setContentHuggingPriority(.required, for: .vertical)

        poweredByButton.isUserInteractionEnabled = true
        poweredByButton.translatesAutoresizingMaskIntoConstraints = false
        poweredByButton.showsTouchWhenHighlighted = false
        poweredByButton.accessibilityIdentifier = "PoweredByParraButton"
        poweredByButton.setContentHuggingPriority(.init(999),
                                                  for: .vertical)
        poweredByButton.addTarget(self,
                                  action: #selector(openParraLink),
                                  for: .touchUpInside)
        
        let defaultAttributes = [NSAttributedString.Key.kern: 0.24]
        let poweredBy = NSMutableAttributedString(
            string: "Powered by ",
            attributes: defaultAttributes
        )

        poweredBy.addAttributes(
            [.font: UIFont.systemFont(ofSize: 8.0, weight: .bold)],
            range: NSMakeRange(0, poweredBy.length)
        )
        
        let font = UIFont(name: "Pacifico-Regular", size: 11) ?? UIFont.boldSystemFont(ofSize: 11)
        let parra = NSMutableAttributedString(
            string: "Parra",
            attributes: [.font: font]
        )
        parra.addAttributes(defaultAttributes,
                            range: NSMakeRange(0, parra.length))
        poweredBy.append(parra)

        poweredByButton.setAttributedTitle(poweredBy, for: .normal)
        poweredByButton.setAttributedTitle(poweredBy, for: .highlighted)

        NSLayoutConstraint.activate([
            poweredByContainer.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: LayoutConstants.navigationPadding
            ),
            poweredByContainer.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: LayoutConstants.contentPadding
            ),
            poweredByContainer.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -LayoutConstants.contentPadding
            ),
            poweredByButton.centerXAnchor.constraint(
                equalTo: poweredByContainer.centerXAnchor
            ),
            poweredByButton.topAnchor.constraint(
                equalTo: poweredByContainer.topAnchor
            ),
            poweredByButton.bottomAnchor.constraint(
                equalTo: poweredByContainer.bottomAnchor
            )
        ])
    }

    @objc private func openParraLink() {
        Parra.logAnalyticsEvent(ParraSessionEventType.action(
            source: "powered-by-parra",
            module: ParraFeedback.self
        ))

        UIApplication.shared.open(Parra.Constant.parraWebRoot)
    }
}
