//
//  FeedbackCardWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

// MARK: - FeedbackCardWidget.ContentObserver

extension FeedbackCardWidget {
    @MainActor
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        init(
            notificationCenter: NotificationCenterType,
            syncHandler: (() -> Void)?
        ) {
            self.showNavigation = true
            self.notificationCenter = notificationCenter
            self.syncHandler = syncHandler

            let backButton = ButtonContent(
                type: .image(ImageContent.symbol("arrow.backward")),
                isDisabled: false,
                onPress: nil
            )

            let forwardButton = ButtonContent(
                type: .image(ImageContent.symbol("arrow.forward")),
                isDisabled: false,
                onPress: nil
            )

            self.content = Content(
                backButton: backButton,
                forwardButton: forwardButton
            )

            self.cards = ParraCardItem.validStates() // TODO:
            self.currentCard = cards.first

            content.backButton.onPress = onPressBack
            content.forwardButton.onPress = onPressForward

            checkAndUpdateCards()
        }

        deinit {
            Task {
                self.syncHandler?()
            }
        }

        // MARK: - Internal

        @MainActor
        struct Content: ContainerContent {
            // MARK: - Lifecycle

            init(
                backButton: ButtonContent,
                forwardButton: ButtonContent
            ) {
                self.backButton = backButton
                self.forwardButton = forwardButton
            }

            // MARK: - Internal

            fileprivate(set) var backButton: ButtonContent
            fileprivate(set) var forwardButton: ButtonContent
        }

        @Published private(set) var content: Content
        @Published private(set) var cards: [ParraCardItem]

        /// The currently selected card, if one exists.
        @Published private(set) var currentCard: ParraCardItem?

        @Published fileprivate(set) var showNavigation: Bool

        let answerHandler = ParraCardAnswerHandler()

        func startObservingCardChangeNotifications() {
            notificationCenter.addObserver(
                self,
                selector: #selector(
                    didReceiveCardChangeNotification(notification:)
                ),
                name: ParraFeedback.cardsDidChangeNotification,
                object: nil
            )
        }

        func stopObservingCardChangeNotifications() {
            notificationCenter.removeObserver(
                self,
                name: ParraFeedback.cardsDidChangeNotification,
                object: nil
            )
        }

        // MARK: - Private

        private let notificationCenter: NotificationCenterType
        private let syncHandler: (() -> Void)?

        private func onPressBack() {
            //            suggestTransitionInDirection(.left, animated: true)
        }

        private func onPressForward() {
            // Currently only used on card types that don't have a straight forward way of determining that the user
            // is done interacting with them (currently long text and checkbox). It is implied that cards like this
            // shouldn't be manually commiting to the answer handler, since this action is taken here.
            //            currentCardInfo?.cardItemView.commitToSelection()
        }

        @objc
        private func didReceiveCardChangeNotification(
            notification: Notification
        ) {
            checkAndUpdateCards()
        }

        private func checkAndUpdateCards() {
            Task {
//                let newCards = await ParraFeedback.shared.dataManager.currentCards()
//
//                await MainActor.run {
//                    cards = newCards
//                }
            }
        }
    }
}
