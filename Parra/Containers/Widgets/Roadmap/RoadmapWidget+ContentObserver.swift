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
            ticketResponse: UserTicketCollectionResponse,
            networkManager: ParraNetworkManager
        ) {
            let addRequestButton = TextButtonContent(
                text: LabelContent(text: "Add request"),
                isDisabled: false,
                onPress: nil
            )

            self.roadmapConfig = roadmapConfig
            self.networkManager = networkManager
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
        @Published var selectedTab: Tab = .inProgress

        func fetchUpdatedRoadmap() {
            // Refresh the data for all the tabs, but start with the currently
            // selected one. Once it is finished all the others can begin
            Tab.allCases
        }

        // MARK: - Private

        private let roadmapConfig: AppRoadmapConfiguration
        private let networkManager: ParraNetworkManager

        private func addRequest() {
            guard let form = roadmapConfig.form else {
                return
            }

            addRequestForm = ParraFeedbackForm(from: form)
        }

        private func onUpvote(_ ticket: UserTicket) {}

        private func stuff() async {
//            networkManager.getCards(appArea: <#T##ParraQuestionAppArea#>)
        }
    }
}
