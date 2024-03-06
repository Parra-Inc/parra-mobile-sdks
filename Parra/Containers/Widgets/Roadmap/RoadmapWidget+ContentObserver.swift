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
    class ContentObserver: ContainerContentObserver, TicketContentDelegate {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            let initialTab = initialParams.selectedTab
            let roadmapConfig = initialParams.roadmapConfig
            let ticketResponse = initialParams.ticketResponse

            let addRequestButton = TextButtonContent(
                text: LabelContent(text: "Add request"),
                isDisabled: false,
                onPress: nil
            )

            self.selectedTab = initialTab
            self.roadmapConfig = roadmapConfig
            self.canAddRequests = roadmapConfig.form != nil
            self.networkManager = initialParams.networkManager
            self.content = Content(
                title: "Roadmap",
                addRequestButton: addRequestButton
            )

            self.tickets = ticketResponse.data.map {
                TicketContent($0, delegate: self)
            }
            // Cache the initial tickets
            ticketCache[initialTab] = tickets

            content.addRequestButton.onPress = addRequest
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        @Published private(set) var content: Content
        @Published private(set) var canAddRequests: Bool

        @Published var addRequestForm: ParraFeedbackForm?
        @Published var tickets: [TicketContent] = []
        @Published var isLoading: Bool = false

        @Published var selectedTab: Tab {
            willSet(newTab) {
                tabWillChange(to: newTab)
            }
        }

        // MARK: - TicketContentDelegate

        @MainActor
        func ticketContentDidReceiveVote(
            _ ticketContent: TicketContent
        ) {
            Task {
                let response = await networkManager.voteForTicket(
                    with: ticketContent.id
                )

                if response.context.statusCode == 409 {
                    // User had already voted for this ticket
                }
                switch response.result {
                case .success(let response):
                    print(response)
                case .failure(let error):
                    print(error)
                }
            }
        }

        @MainActor
        func ticketContentDidRemoveVote(
            _ ticketContent: TicketContent
        ) {
            Task {
                let response = await networkManager.removeVoteForTicket(
                    with: ticketContent.id
                )

                if response.context.statusCode == 409 {
                    // User had already removed their vote for this ticket
                }

                switch response.result {
                case .success(let response):
                    print(response)
                case .failure(let error):
                    print(error)
                }
            }
        }

        // MARK: - Private

        private let roadmapConfig: AppRoadmapConfiguration
        private let networkManager: ParraNetworkManager
        private var ticketCache = [RoadmapWidget.Tab: [TicketContent]]()

        private func tabWillChange(to newTab: Tab) {
            print("tab will change to: \(newTab)")
        }

        private func addRequest() {
            guard let form = roadmapConfig.form else {
                return
            }

            addRequestForm = ParraFeedbackForm(from: form)
        }
    }
}
