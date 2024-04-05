//
//  FeedbackCardWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackCardWidget.ContentObserver {
    struct InitialParams {
        // MARK: - Lifecycle

        init(
            cards: [ParraCardItem],
            notificationCenter: NotificationCenterType,
            dataManager: ParraFeedbackDataManager,
            cardDelegate: ParraCardViewDelegate? = nil,
            questionHandlerDelegate: ParraQuestionHandlerDelegate? = nil,
            syncHandler: (() -> Void)?
        ) {
            self.cards = cards
            self.notificationCenter = notificationCenter
            self.dataManager = dataManager
            self.cardDelegate = cardDelegate
            self.questionHandlerDelegate = questionHandlerDelegate
            self.syncHandler = syncHandler
        }

        // MARK: - Internal

        let cards: [ParraCardItem]
        let notificationCenter: NotificationCenterType
        let dataManager: ParraFeedbackDataManager
        let cardDelegate: ParraCardViewDelegate?
        let questionHandlerDelegate: ParraQuestionHandlerDelegate?
        let syncHandler: (() -> Void)?
    }
}
