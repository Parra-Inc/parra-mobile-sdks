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
        static let navigationPadding: CGFloat = 10
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
        
        let heightConstraint = heightAnchor.constraint(
            greaterThanOrEqualToConstant: Dimensions.minHeight
        )
        
        constraintsOnSuperView = [widthConstraint, heightConstraint]
        
        NSLayoutConstraint.activate(constraintsOnSuperView)
    }
    
    internal func configureSubviews(config: ParraCardViewConfig) {        
        configureContentView()
        configureNavigationStack()

        containerLeadingConstraint = containerView.leadingAnchor.constraint(
            equalTo: leadingAnchor, constant: config.contentInsets.left
        )
        containerTrailingConstraint = containerView.trailingAnchor.constraint(
            equalTo: trailingAnchor, constant: -config.contentInsets.right
        )
        containerTopConstraint = containerView.topAnchor.constraint(
            equalTo: topAnchor, constant: config.contentInsets.top
        )
        containerBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: bottomAnchor, constant: -config.contentInsets.bottom
        )
        
        NSLayoutConstraint.activate(constraintsOncontainerView)
        
        applyConfig(config)
        
        transitionToNextCard(animated: false)
    }
    
    internal func applyConfig(_ config: ParraCardViewConfig) {
        containerView.backgroundColor = config.backgroundColor
        containerView.layer.cornerRadius = config.cornerRadius
        
        poweredByButton.setTitleColor(config.backgroundColor.isLight()
                                      ? UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.1)
                                      : UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 0.2),
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
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = true
        contentView.accessibilityIdentifier = "ParraFeedbackContentView"
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: navigationStack.bottomAnchor, constant: LayoutConstants.navigationPadding),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
    }
    
    private func configureNavigationStack() {
        navigationStack.translatesAutoresizingMaskIntoConstraints = false
        navigationStack.alignment = .center
        navigationStack.axis = .horizontal
        navigationStack.distribution = .equalSpacing
        navigationStack.isUserInteractionEnabled = true
        navigationStack.accessibilityIdentifier = "ParraFeedbackNavigation"

        poweredByButton.isUserInteractionEnabled = true
        poweredByButton.accessibilityIdentifier = "ParraFeedbackPoweredBy"

        poweredByButton.addTarget(self, action: #selector(openParraLink), for: .touchUpInside)
        
        let defaultAttributes = [NSAttributedString.Key.kern: 0.24]
        let poweredBy = NSMutableAttributedString(string: "Powered by ", attributes: defaultAttributes)
        poweredBy.addAttributes([.font: UIFont.boldSystemFont(ofSize: 12.0)], range: NSMakeRange(0, poweredBy.length))
        
        let font = UIFont(name: "Pacifico-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        let parra = NSMutableAttributedString(string: "Parra", attributes: [.font: font])
        parra.addAttributes(defaultAttributes, range: NSMakeRange(0, parra.length))
        poweredBy.append(parra)

        poweredByButton.setAttributedTitle(poweredBy, for: .normal)
        
        NSLayoutConstraint.activate([
            navigationStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            navigationStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            navigationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }

    @objc private func openParraLink() {
        UIApplication.shared.open(Parra.Constant.parraWebRoot)
    }
}
