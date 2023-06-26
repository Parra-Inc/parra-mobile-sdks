//
//  ParraCardView+Transitions.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit

extension ParraCardView: ParraQuestionHandlerDelegate {
    internal func questionHandlerDidMakeNewSelection(forQuestion question: Question) async {
        try? await Task.sleep(nanoseconds: 333_000_000)

        let (nextCardItem, nextCardItemDiection) = nextCardItem(inDirection: .right)

        guard let nextCardItem = nextCardItem, nextCardItemDiection == .right else {
            return
        }

        guard !(await ParraFeedback.hasCardBeenCompleted(nextCardItem)) else {
            return
        }

        // If there is a next card, we ask the delegate if we should transition.
        let shouldTransition = delegate?.parraCardView(self, shouldAutoNavigateTo: nextCardItem) ?? true

        if shouldTransition {
            suggestTransitionInDirection(.right, animated: true)
        }
    }
}

extension ParraCardView {
    internal func suggestTransitionInDirection(_ direction: Direction,
                                               animated: Bool) {
        
        guard canTransitionInDirection(direction) else {
            return
        }
        
        transitionToNextCard(
            direction: direction,
            animated: animated
        )
    }
    
    internal func transitionToNextCard(direction: Direction = .right,
                                       animated: Bool = false) {
        
        let (nextCardItem, nextCardItemDiection) = nextCardItem(inDirection: direction)
        
        transitionToCardItem(nextCardItem,
                             direction: nextCardItemDiection,
                             animated: animated)
    }
    
    internal func nextCardItem(inDirection direction: Direction) -> (nextCardItem: ParraCardItem?, nextCardItemDirection: Direction) {
        guard let currentCardInfo = currentCardInfo else {
            return (cardItems.first, direction)
        }
        
        if let currentIndex = cardItems.firstIndex(where: { $0 == currentCardInfo.cardItem }) {
            switch direction {
            case .left:
                if currentIndex == 0 {
                    return (cardItems.last, .left)
                } else {
                    return (cardItems[currentIndex - 1], .left)
                }
            case .right:
                if currentIndex == cardItems.count - 1 {
                    return (nil, .right)
                } else {
                    return (cardItems[currentIndex + 1], .right)
                }
            }
        } else {
            // You're all caught up for now condition
            switch direction {
            case .left:
                return (cardItems.last, .left)
            case .right:
                return (cardItems.first, .right)
            }
        }
    }
    
    internal func transitionToCardItem(_ cardItem: ParraCardItem?,
                                       direction: Direction,
                                       animated: Bool = false) {
        
        let nextCard = cardViewFromCardItem(cardItem)
        nextCard.accessibilityIdentifier = "Next Card"

        let visibleButtons = visibleNavigationButtonsForCardItem(cardItem)

        contentView.addSubview(nextCard)

        // If these change, make sure that changing nextCard.frame below still makes sense.
        NSLayoutConstraint.activate([
            nextCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nextCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            nextCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        delegate?.parraCardView(self, willDisplay: cardItem)
        
        if animated {
            let oldCardInfo = currentCardInfo

            forwardButton.isEnabled = false

            self.currentCardInfo?.cardItemView.transform = .identity
            
            nextCard.frame = CGRect(origin: .zero, size: contentView.bounds.size)
            nextCard.setNeedsLayout()
            nextCard.transform = .identity.translatedBy(
                x: direction == .right ? self.frame.width : -self.frame.width,
                y: 0.0
            )
            
            contentView.invalidateIntrinsicContentSize()
            contentView.setNeedsUpdateConstraints()
            
            // Not starting the animation until the view has a chance to re-render after setNeedsDisplay
            DispatchQueue.main.async {
                self.currentCardInfo = CurrentCardInfo(
                    cardItemView: nextCard,
                    cardItem: cardItem
                )
                if let oldCardInfo {
                    self.delegate?.parraCardView(self, willEndDisplaying: oldCardInfo.cardItem)
                }
                
                self.layoutIfNeeded()
                
                UIView.animate(
                    withDuration: 0.375,
                    delay: 0.0,
                    options: [.curveEaseInOut, .beginFromCurrentState]) {
                        oldCardInfo?.cardItemView.transform = .identity.translatedBy(
                            x: direction == .right ? -self.frame.width : self.frame.width,
                            y: 0.0
                        )
                        nextCard.transform = .identity
                        self.layoutIfNeeded()

                        self.updateVisibleNavigationButtons(visibleButtons: visibleButtons)
                    } completion: { _ in
                        if let oldCardInfo {
                            NSLayoutConstraint.deactivate(oldCardInfo.cardItemView.constraints)
                            oldCardInfo.cardItemView.removeFromSuperview()
                            
                            self.delegate?.parraCardView(self, didEndDisplaying: oldCardInfo.cardItem)
                        }
                        
                        self.sendDidDisplay(cardItem: cardItem)
                    }
            }
        } else {
            updateVisibleNavigationButtons(visibleButtons: visibleButtons)

            if let currentCardInfo {
                delegate?.parraCardView(self, willEndDisplaying: currentCardInfo.cardItem)
                
                NSLayoutConstraint.deactivate(currentCardInfo.cardItemView.constraints)
                currentCardInfo.cardItemView.removeFromSuperview()
                self.currentCardInfo = nil
                
                delegate?.parraCardView(self, didEndDisplaying: currentCardInfo.cardItem)
            }
            
            self.currentCardInfo = CurrentCardInfo(
                cardItemView: nextCard,
                cardItem: cardItem
            )
            
            self.sendDidDisplay(cardItem: cardItem)
        }
    }

    private func sendDidDisplay(cardItem: ParraCardItem?) {
        self.delegate?.parraCardView(self, didDisplay: cardItem)

        if let cardItem {
            Parra.logEvent(.view(element: "question"), params: [
                "question_id": cardItem.id
            ])
        }
    }

    internal func visibleNavigationButtonsForCardItem(_ cardItem: ParraCardItem?) -> VisibleButtonOptions {
        guard let cardItem = cardItem else {
            return []
        }

        var visibleButtons: VisibleButtonOptions = []

        if cardItem.requiresManualNextSelection {
            visibleButtons.update(with: .forward)
        }

        return visibleButtons
    }
    
    private func canTransitionInDirection(_ direction: Direction) -> Bool {
        guard let currentCardInfo = currentCardInfo else {
            return false
        }
        
        guard let currentIndex = cardItems.firstIndex(where: { $0 == currentCardInfo.cardItem }) else {
            return false
        }
        
        switch direction {
        case .left:
            return currentIndex > 0
        case .right:
            return currentIndex < cardItems.count - 1
        }
    }

    internal func updateVisibleNavigationButtons(visibleButtons: VisibleButtonOptions) {
        let showBack = visibleButtons.contains(.back)

        backButton.alpha = showBack ? 1.0 : 0.0
        backButton.isEnabled = showBack

        let showForward = visibleButtons.contains(.forward)

        forwardButton.alpha = showForward ? 1.0 : 0.0
        forwardButton.isEnabled = showForward
    }
    
    private func cardViewFromCardItem(_ cardItem: ParraCardItem?) -> ParraCardItemView {
        guard let cardItem = cardItem else {
            if let userProvidedEmptyState = delegate?.completeStateViewForParraCardView(self) {
                return ParraEmptyCardView(innerView: userProvidedEmptyState)
            } else {
                return defaultActionCardView {
                    self.delegate?.parraCardViewDidRequestDismissal(self)
                }
            }
        }
        
        let card: ParraCardItemView
        switch (cardItem.data) {
        case .question(let question):
            card = ParraQuestionCardView(
                bucketId: cardItem.id,
                question: question,
                answerHandler: answerHandler,
                config: config
            )
        }
        
        return card
    }
    
    internal func defaultActionCardView(
        with actionHandler: (() -> Void)?) -> ParraActionCardView {

        return ParraActionCardView(
            config: config,
            title: "You're all caught up for now!",
            subtitle: "We appreciate you taking the time to provide us with your feedback.",
            actionTitle: "Dismiss",
            actionHandler: actionHandler
        )
    }
}
