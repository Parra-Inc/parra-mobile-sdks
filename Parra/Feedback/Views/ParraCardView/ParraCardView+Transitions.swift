//
//  ParraCardView+Transitions.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit

// MARK: - ParraCardView + ParraQuestionHandlerDelegate

extension ParraCardView: ParraQuestionHandlerDelegate {
    func questionHandlerDidMakeNewSelection(
        forQuestion question: Question
    ) async {
        try? await Task.sleep(for: 0.333)

        let (
            nextCardItem,
            nextCardItemDiection
        ) = nextCardItem(inDirection: .right)

        guard let nextCardItem, nextCardItemDiection == .right else {
            return
        }

        guard await !(ParraFeedback.shared.hasCardBeenCompleted(nextCardItem)) else {
            return
        }

        // If there is a next card, we ask the delegate if we should transition.
        let shouldTransition = delegate?.parraCardView(
            self,
            shouldAutoNavigateTo: nextCardItem
        ) ?? true

        if shouldTransition {
            suggestTransitionInDirection(.right, animated: true)
        }
    }
}

extension ParraCardView {
    func suggestTransitionInDirection(
        _ direction: Direction,
        animated: Bool
    ) {
        guard canTransitionInDirection(direction) else {
            return
        }

        transitionToNextCard(
            direction: direction,
            animated: animated
        )
    }

    func transitionToNextCard(
        direction: Direction = .right,
        animated: Bool = false
    ) {
        let (
            nextCardItem,
            nextCardItemDiection
        ) = nextCardItem(inDirection: direction)

        transitionToCardItem(
            nextCardItem,
            direction: nextCardItemDiection,
            animated: animated
        )
    }

    func nextCardItem(inDirection direction: Direction)
        -> (nextCardItem: ParraCardItem?, nextCardItemDirection: Direction)
    {
        guard let currentCardInfo else {
            return (cardItems.first, direction)
        }

        if let currentIndex = cardItems
            .firstIndex(where: { $0 == currentCardInfo.cardItem })
        {
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

    func transitionToCardItem(
        _ cardItem: ParraCardItem?,
        direction: Direction,
        animated: Bool = false
    ) {
        let nextCard = cardViewFromCardItem(cardItem)
        nextCard.accessibilityIdentifier = "Next Card"

        let visibleButtons = visibleNavigationButtonsForCardItem(cardItem)

        contentView.addSubview(nextCard)

        // If these change, make sure that changing nextCard.frame below still makes sense.
        NSLayoutConstraint.activate([
            nextCard.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            nextCard.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            nextCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            nextCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        delegate?.parraCardView(self, willDisplay: cardItem)

        if animated {
            let oldCardInfo = currentCardInfo

            forwardButton.isEnabled = false

            currentCardInfo?.cardItemView.transform = .identity

            nextCard.frame = CGRect(
                origin: .zero,
                size: contentView.bounds.size
            )
            nextCard.setNeedsLayout()
            nextCard.transform = .identity.translatedBy(
                x: direction == .right ? frame.width : -frame.width,
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
                    self.delegate?.parraCardView(
                        self,
                        willEndDisplaying: oldCardInfo.cardItem
                    )
                }

                self.layoutIfNeeded()

                UIView.animate(
                    withDuration: 0.375,
                    delay: 0.0,
                    options: [.curveEaseInOut, .beginFromCurrentState]
                ) {
                    oldCardInfo?.cardItemView.transform = .identity
                        .translatedBy(
                            x: direction == .right ? -self.frame.width : self
                                .frame.width,
                            y: 0.0
                        )
                    nextCard.transform = .identity
                    self.layoutIfNeeded()

                    self
                        .updateVisibleNavigationButtons(
                            visibleButtons: visibleButtons
                        )
                } completion: { _ in
                    if let oldCardInfo {
                        NSLayoutConstraint
                            .deactivate(
                                oldCardInfo.cardItemView
                                    .constraints
                            )
                        oldCardInfo.cardItemView.removeFromSuperview()

                        self.delegate?.parraCardView(
                            self,
                            didEndDisplaying: oldCardInfo.cardItem
                        )
                    }

                    self.sendDidDisplay(cardItem: cardItem)
                }
            }
        } else {
            updateVisibleNavigationButtons(visibleButtons: visibleButtons)

            if let currentCardInfo {
                delegate?.parraCardView(
                    self,
                    willEndDisplaying: currentCardInfo.cardItem
                )

                NSLayoutConstraint
                    .deactivate(currentCardInfo.cardItemView.constraints)
                currentCardInfo.cardItemView.removeFromSuperview()
                self.currentCardInfo = nil

                delegate?.parraCardView(
                    self,
                    didEndDisplaying: currentCardInfo.cardItem
                )
            }

            currentCardInfo = CurrentCardInfo(
                cardItemView: nextCard,
                cardItem: cardItem
            )

            sendDidDisplay(cardItem: cardItem)
        }
    }

    private func sendDidDisplay(cardItem: ParraCardItem?) {
        delegate?.parraCardView(self, didDisplay: cardItem)

        if let cardItem {
            // TODO: SwiftUI hook into shared instance

//            Parra.logEvent(.view(element: "question"), [
//                "question_id": cardItem.id
//            ])
        }
    }

    func visibleNavigationButtonsForCardItem(_ cardItem: ParraCardItem?)
        -> VisibleButtonOptions
    {
        guard let cardItem else {
            return []
        }

        var visibleButtons: VisibleButtonOptions = []

        if cardItem.requiresManualNextSelection {
            visibleButtons.update(with: .forward)
        }

        return visibleButtons
    }

    private func canTransitionInDirection(_ direction: Direction) -> Bool {
        guard let currentCardInfo else {
            return false
        }

        guard let currentIndex = cardItems
            .firstIndex(where: { $0 == currentCardInfo.cardItem }) else
        {
            return false
        }

        switch direction {
        case .left:
            return currentIndex > 0
        case .right:
            return currentIndex < cardItems.count - 1
        }
    }

    func updateVisibleNavigationButtons(visibleButtons: VisibleButtonOptions) {
        let showBack = visibleButtons.contains(.back)

        backButton.alpha = showBack ? 1.0 : 0.0
        backButton.isEnabled = showBack

        let showForward = visibleButtons.contains(.forward)

        forwardButton.alpha = showForward ? 1.0 : 0.0
        forwardButton.isEnabled = showForward
    }

    private func cardViewFromCardItem(_ cardItem: ParraCardItem?)
        -> ParraCardItemView
    {
        guard let cardItem else {
            if let userProvidedEmptyState = delegate?
                .completeStateViewForParraCardView(self)
            {
                return ParraEmptyCardView(innerView: userProvidedEmptyState)
            } else {
                return defaultActionCardView {
                    self.delegate?.parraCardViewDidRequestDismissal(self)
                }
            }
        }

        let card: ParraCardItemView = switch cardItem.data {
        case .question(let question):
            ParraQuestionCardView(
                bucketId: cardItem.id,
                question: question,
                answerHandler: answerHandler,
                config: config
            )
        }

        return card
    }

    func defaultActionCardView(
        with actionHandler: (() -> Void)?
    ) -> ParraActionCardView {
        return ParraActionCardView(
            config: config,
            title: "You're all caught up for now!",
            subtitle: "We appreciate you taking the time to provide us with your feedback.",
            actionTitle: "Dismiss",
            actionHandler: actionHandler
        )
    }
}
