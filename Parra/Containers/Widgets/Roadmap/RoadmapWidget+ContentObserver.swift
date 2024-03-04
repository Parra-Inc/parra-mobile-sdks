//
//  RoadmapWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

// MARK: - RoadmapWidget.ContentObserver

extension RoadmapWidget {
    @MainActor
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        init(
            roadmapConfig: AppRoadmapConfiguration,
            ticketResponse: UserTicketCollectionResponse
        ) {
            let addRequestButton = ButtonContent(
                type: .text(
                    LabelContent(text: "Add request")
                ),
                isDisabled: false,
                onPress: nil
            )

            self.roadmapConfig = roadmapConfig
            self.content = Content(
                title: "Roadmap",
                addRequestButton: addRequestButton,
                tickets: ticketResponse.data
            )

            self.canAddRequests = roadmapConfig.form != nil

            content.addRequestButton.onPress = addRequest
            content.onUpvote = onUpvote
        }

        // MARK: - Internal

        @Published private(set) var content: Content
        @Published var addRequestForm: ParraFeedbackForm?
        @Published private(set) var canAddRequests: Bool

        // MARK: - Private

        private let roadmapConfig: AppRoadmapConfiguration

        private func addRequest() {
            guard let form = roadmapConfig.form else {
                return
            }

            addRequestForm = ParraFeedbackForm(from: form)
        }

        private func onUpvote(_ ticket: UserTicket) {}
    }
}
