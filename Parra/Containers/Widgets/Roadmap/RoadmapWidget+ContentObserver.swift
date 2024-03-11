//
//  RoadmapWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Combine
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

            let initialPaginatorData = Paginator<
                TicketContent,
                RoadmapWidget.Tab
            >.Data(
                items: ticketResponse.data.map {
                    TicketContent($0, delegate: self)
                },
                placeholderItems: [],
                pageSize: ticketResponse.pageSize,
                knownCount: ticketResponse.totalCount
            )

            let initialPaginator = Paginator<TicketContent, RoadmapWidget.Tab>(
                context: initialTab,
                data: initialPaginatorData,
                pageFetcher: loadMoreTickets
            )

            self.ticketPaginator = initialPaginator
            // Cache the initial tickets
            ticketCache[initialTab] = initialPaginatorData

            content.addRequestButton.onPress = addRequest
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        @Published private(set) var content: Content
        @Published private(set) var canAddRequests: Bool

        @Published var addRequestForm: ParraFeedbackForm?

        @Published private(set) var ticketPaginator: Paginator<
            TicketContent,
            RoadmapWidget.Tab
                // Using IUO because this object requires referencing self in a closure
                // in its init so we need all fields set. Post-init this should always
                // be set.
        >! {
            willSet {
                paginatorSink?.cancel()
                paginatorSink = nil
            }

            didSet {
                paginatorSink = ticketPaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                        self?.updateCacheForCurrentPaginator()
                    }
            }
        }

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

        private var paginatorSink: AnyCancellable? = nil

        private let roadmapConfig: AppRoadmapConfiguration
        private let networkManager: ParraNetworkManager
        private var ticketCache = [
            RoadmapWidget.Tab: Paginator<TicketContent, RoadmapWidget.Tab>.Data
        ]()

        private func updateCacheForCurrentPaginator() {
            let tab = ticketPaginator.context

            ticketCache[tab] = .init(
                items: ticketPaginator.items,
                knownCount: ticketPaginator.totalCount
            )
        }

        private func tabWillChange(to newTab: Tab) {
            if let cachedData = ticketCache[newTab] {
                print("tab will change to cached tab: \(newTab)")

                ticketPaginator = Paginator<TicketContent, RoadmapWidget.Tab>(
                    context: newTab,
                    data: cachedData,
                    pageFetcher: loadMoreTickets
                )
            } else {
                print("tab will change to new tab: \(newTab)")

                let newPageData = Paginator<TicketContent, RoadmapWidget.Tab>
                    .Data(
                        items: [],
                        placeholderItems: (0 ... 15)
                            .map { _ in TicketContent.redacted }
                    )

                ticketPaginator = Paginator<TicketContent, RoadmapWidget.Tab>(
                    context: newTab,
                    data: newPageData,
                    pageFetcher: loadMoreTickets
                )
            }
        }

        private func loadMoreTickets(
            _ limit: Int,
            _ offset: Int,
            _ tab: RoadmapWidget.Tab
        ) async throws -> [TicketContent] {
            let response = try await networkManager.paginateTickets(
                limit: limit,
                offset: offset,
                filter: tab.filter
            )

            return response.data.map {
                TicketContent($0, delegate: self)
            }
        }

        private func addRequest() {
            guard let form = roadmapConfig.form else {
                return
            }

            addRequestForm = ParraFeedbackForm(from: form)
        }
    }
}
