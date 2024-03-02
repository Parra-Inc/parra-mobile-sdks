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

struct CurrentCardInfo: Equatable {
    let card: ParraCardItem
    let index: Int
}

// MARK: - FeedbackCardWidget.ContentObserver

extension FeedbackCardWidget {
    @MainActor
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        init(
            cards: [ParraCardItem],
            notificationCenter: NotificationCenterType,
            dataManager: ParraFeedbackDataManager,
            cardDelegate: ParraCardViewDelegate? = nil,
            questionHandlerDelegate: ParraQuestionHandlerDelegate? = nil,
            syncHandler: (() -> Void)?
        ) {
            self.showNavigation = true
            self.notificationCenter = notificationCenter
            self.dataManager = dataManager
            self.cardDelegate = cardDelegate
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

            self.cards = cards
            self.currentCardInfo = if let first = cards.first {
                CurrentCardInfo(card: first, index: 0)
            } else {
                nil
            }

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
        @Published private(set) var currentCardInfo: CurrentCardInfo?

        @Published fileprivate(set) var showNavigation: Bool

        @Published private(set) var currentAnswerState: AnswerStateMap = [:]

        func currentAnswer<T: AnswerOption>(
            for bucketItemId: String
        ) -> T? {
            print("Getting current answer...")
            guard let value = currentAnswerState[bucketItemId] else {
                return nil
            }

            return value.data as? T
        }

        func update(
            answer: QuestionAnswer?,
            for bucketItemId: String
        ) {
            print("Updating answer...")
            currentAnswerState[bucketItemId] = answer
        }

        func commitAnswers(
            for bucketItemId: String,
            question: Question
        ) {
            print("Commiting answer...")
            guard let answer = currentAnswerState[bucketItemId] else {
                // This check is critical since it's possible that a card could commit a selection change
                // without any answers selected.
                return
            }

            let completedCard = CompletedCard(
                bucketItemId: bucketItemId,
                questionId: question.id,
                data: answer
            )

            Task {
                await dataManager.completeCard(completedCard)

                // This should only be invoked when a new selection is made, not when it changes
                await questionHandlerDelegate?
                    .questionHandlerDidMakeNewSelection(
                        forQuestion: question
                    )
            }
        }

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

        private weak var cardDelegate: ParraCardViewDelegate?
        private weak var questionHandlerDelegate: ParraQuestionHandlerDelegate?

        private let notificationCenter: NotificationCenterType
        private let dataManager: ParraFeedbackDataManager
        private let syncHandler: (() -> Void)?

        private func onPressBack() {
            guard let currentCardInfo else {
                return
            }

            var nextIndex = currentCardInfo.index - 1
            if !cards.indices.contains(nextIndex) {
                nextIndex = cards.count - 1
            }

            self.currentCardInfo = CurrentCardInfo(
                card: cards[nextIndex],
                index: nextIndex
            )

            //            suggestTransitionInDirection(.left, animated: true)
        }

        private func onPressForward() {
            guard let currentCardInfo else {
                return
            }

            var nextIndex = currentCardInfo.index + 1
            if !cards.indices.contains(nextIndex) {
                nextIndex = 0
            }

            self.currentCardInfo = CurrentCardInfo(
                card: cards[nextIndex],
                index: nextIndex
            )

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