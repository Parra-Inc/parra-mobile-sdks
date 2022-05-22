//
//  ParraFeedbackView+Layout.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit

extension ParraFeedbackView {
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
    
    internal func configureSubviews(config: ParraFeedbackViewConfig) {        
        configureContentView()
        configureNavigationStack()
        
        addCardSwipeGesture(toView: contentView, direction: .right)
        addCardSwipeGesture(toView: contentView, direction: .left)
        addCardSwipeGesture(toView: containerView, direction: .right)
        addCardSwipeGesture(toView: containerView, direction: .left)

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

    internal func applyConfig(_ config: ParraFeedbackViewConfig) {
        containerView.backgroundColor = config.backgroundColor
        containerView.layer.cornerRadius = config.cornerRadius

        backButton.tintColor = config.tintColor
        backButton.accessibilityIdentifier = "ParraFeedbackNavigationBackButton"
        forwardButton.tintColor = config.tintColor
        forwardButton.accessibilityIdentifier = "ParraFeedbackNavigationForwardButton"

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

        poweredByLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        poweredByLabel.textColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.1)
        poweredByLabel.textAlignment = .center
        poweredByLabel.isUserInteractionEnabled = true
        poweredByLabel.accessibilityIdentifier = "ParraFeedbackPoweredBy"

        let defaultAttributes = [NSAttributedString.Key.kern: 0.24]
        let poweredBy = NSMutableAttributedString(string: "Powered by ", attributes: defaultAttributes)
        
        let font = UIFont(name: "Pacifico-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        let parra = NSMutableAttributedString(string: "Parra", attributes: [.font: font])
        parra.addAttributes(defaultAttributes, range: NSMakeRange(0, parra.length))
        poweredBy.append(parra)
        
        poweredByLabel.attributedText = poweredBy
        
        NSLayoutConstraint.activate([
            navigationStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            navigationStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            navigationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }

    private func addCardSwipeGesture(toView view: UIView, direction: Direction) {
        let gesture = createSwipeGesture(
            inDirection: direction.swipeDirection,
            selector: direction == .left
                ? #selector(navigateToNextCard)
                : #selector(navigateToPreviousCard)
        )
        
        view.addGestureRecognizer(gesture)
        cardSwipeGestureRecognizers.append(gesture)
    }

    private func createSwipeGesture(inDirection direction: UISwipeGestureRecognizer.Direction,
                                    selector: Selector) -> UISwipeGestureRecognizer {

        let swipe = UISwipeGestureRecognizer(target: self, action: selector)
        swipe.direction = direction
        
        return swipe
    }
    
    @objc internal func navigateToPreviousCard() {
        suggestTransitionInDirection(.left, animated: true)
    }
    
    @objc internal func navigateToNextCard() {
        suggestTransitionInDirection(.right, animated: true)
    }
}
