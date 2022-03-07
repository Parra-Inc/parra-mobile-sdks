//
//  ParraFeedbackView+Layout.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit

extension ParraFeedbackView {
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        removeConstraints(constraintsOnSuperView)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {
            return
        }
        
        constraintsOnSuperView = [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraintsOnSuperView)
    }
    
    func configureSubviews(config: ParraFeedbackViewConfig) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.masksToBounds = false
        
        addSubview(containerView)
        containerView.addSubview(navigationStack)
        addSubview(contentView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = true
        
        configureContentView()
        configureNavigationStack()

        let swipePrevious = UISwipeGestureRecognizer(target: self, action: #selector(navigateToPreviousCard))
        swipePrevious.direction = .right
        swipePrevious.delegate = self

        let swipeNext = UISwipeGestureRecognizer(target: self, action: #selector(navigateToNextCard))
        swipeNext.direction = .left
        swipeNext.delegate = self
        
        containerView.addGestureRecognizer(swipePrevious)
        containerView.addGestureRecognizer(swipeNext)

        applyConfig(config)
        
        transitionToNextCard(animated: false)
    }

    private func applyConfig(_ config: ParraFeedbackViewConfig) {
        
        containerView.removeConstraints(constraintsOncontainerView)
        constraintsOncontainerView = [
            containerView.topAnchor.constraint(
                equalTo: topAnchor, constant: config.contentInsets.top
            ),
            containerView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: config.contentInsets.left
            ),
            containerView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -config.contentInsets.bottom
            ),
            containerView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -config.contentInsets.right
            )
        ]
        NSLayoutConstraint.activate(constraintsOncontainerView)
        
        containerView.backgroundColor = config.backgroundColor
        containerView.layer.cornerRadius = config.cornerRadius
        
        backButton.tintColor = config.tintColor
        forwardButton.tintColor = config.tintColor
        
        layer.shadowColor = config.shadowColor.cgColor
        layer.shadowOpacity = Float(config.shadowOpacity)
        layer.shadowRadius = config.shadowRadius
        layer.shadowOffset = config.shadowSize
        layer.bounds = bounds
        layer.position = center
    }
    
    private func configureContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: navigationStack.bottomAnchor, constant: 10),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 170)
        ])
    }
    
    private func configureNavigationStack() {
        navigationStack.translatesAutoresizingMaskIntoConstraints = false
        navigationStack.alignment = .center
        navigationStack.axis = .horizontal
        navigationStack.distribution = .equalSpacing
        navigationStack.isUserInteractionEnabled = true
        
        poweredByLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        poweredByLabel.textColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.1)
        poweredByLabel.textAlignment = .center
        poweredByLabel.isUserInteractionEnabled = true
        
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
    
    @objc func navigateToPreviousCard() {
        suggestTransitionInDirection(.left, animated: true)
    }
    
    @objc func navigateToNextCard() {
        suggestTransitionInDirection(.right, animated: true)
    }
}

extension ParraFeedbackView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
