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
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            let initialTab = initialParams.selectedTab
            let roadmapConfig = initialParams.roadmapConfig
            let ticketResponse = initialParams.ticketResponse

            let addRequestButton = TextButtonContent(
                text: LabelContent(text: "Add request"),
                isDisabled: false
            )

            let emptyStateViewContent = EmptyStateContent(
                title: LabelContent(
                    text: "No tickets yet"
                ),
                subtitle: LabelContent(
                    text: "This is your opportunity to be the first 👀"
                )
            )

            let errorStateViewContent = EmptyStateContent(
                title: EmptyStateContent.errorGeneric.title,
                subtitle: LabelContent(
                    text: "Failed to load roadmap. Please try again later."
                ),
                icon: .symbol("network.slash", .monochrome)
            )

            self.selectedTab = initialTab
            self.roadmapConfig = roadmapConfig
            self.canAddRequests = roadmapConfig.form != nil
            self.networkManager = initialParams.networkManager
            self.tabs = roadmapConfig.tabs
            self.content = Content(
                title: "Roadmap",
                addRequestButton: addRequestButton,
                emptyStateView: emptyStateViewContent,
                errorStateView: errorStateViewContent
            )

            let initialPaginatorData = Paginator<
                TicketUserContent,
                RoadmapConfigurationTab
            >.Data(
                items: ticketResponse.data.map { TicketUserContent($0) },
                placeholderItems: [],
                pageSize: ticketResponse.pageSize,
                knownCount: ticketResponse.totalCount
            )

            let initialPaginator = Paginator<
                TicketUserContent,
                RoadmapConfigurationTab
            >(
                context: initialTab,
                data: initialPaginatorData,
                pageFetcher: loadMoreTickets
            )

            self.ticketPaginator = initialPaginator
            // Cache the initial tickets
            ticketCache[initialTab] = initialPaginatorData

            $currentTicketToVote
                .map(toggleVote)
                .debounce(
                    for: .seconds(2.0),
                    scheduler: DispatchQueue.main
                )
                .asyncMap(submitUpdatedVote)
                .sink(receiveValue: { _ in })
                .store(in: &voteBag)
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        @Published private(set) var content: Content
        @Published private(set) var canAddRequests: Bool

        @Published var addRequestForm: ParraFeedbackForm?

        let networkManager: ParraNetworkManager

        /// The identifier for a ticket to toggle the vote for.
        @Published var currentTicketToVote: String?

        private(set) var ticketCache = [
            RoadmapConfigurationTab: Paginator<
                TicketUserContent,
                RoadmapConfigurationTab
            >.Data
        ]()

        @Published private(set) var tabs: [RoadmapConfigurationTab]

        @Published var ticketPaginator: Paginator<
            TicketUserContent,
            RoadmapConfigurationTab
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

        @Published var selectedTab: RoadmapConfigurationTab {
            willSet(newTab) {
                tabWillChange(to: newTab)
            }
        }

        func updateTicketOnAllTabs(_ ticket: TicketUserContent) {
            let keys = ticketCache.keys
            for key in keys {
                guard let new = ticketCache[key]?.replacingItem(ticket) else {
                    continue
                }

                ticketCache.updateValue(new, forKey: key)
            }
        }

        func addRequest() {
            guard let form = roadmapConfig.form else {
                return
            }

            addRequestForm = ParraFeedbackForm(from: form)
        }

        // MARK: - Private

        private var paginatorSink: AnyCancellable? = nil

        private var voteBag = Set<AnyCancellable>()

        private let roadmapConfig: AppRoadmapConfiguration

        private func updateCacheForCurrentPaginator() {
            let tab = ticketPaginator.context

            ticketCache[tab] = .init(
                items: ticketPaginator.items,
                knownCount: ticketPaginator.totalCount
            )
        }

        private func tabWillChange(to newTab: RoadmapConfigurationTab) {
            if let cachedData = ticketCache[newTab] {
                logger.debug("tab will change to cached tab: \(newTab)")

                ticketPaginator = Paginator<
                    TicketUserContent,
                    RoadmapConfigurationTab
                >(
                    context: newTab,
                    data: cachedData,
                    pageFetcher: loadMoreTickets
                )
            } else {
                logger.debug("tab will change to new tab: \(newTab)")

                let newPageData = Paginator<
                    TicketUserContent,
                    RoadmapConfigurationTab
                >
                .Data(
                    items: [],
                    placeholderItems: (0 ... 15)
                        .map { _ in TicketUserContent.redacted }
                )

                ticketPaginator = Paginator<
                    TicketUserContent,
                    RoadmapConfigurationTab
                >(
                    context: newTab,
                    data: newPageData,
                    pageFetcher: loadMoreTickets
                )
            }

            objectWillChange.send()
        }

        private func loadMoreTickets(
            _ limit: Int,
            _ offset: Int,
            _ tab: RoadmapConfigurationTab
        ) async throws -> [TicketUserContent] {
            let response = try await networkManager.paginateTickets(
                limit: limit,
                offset: offset,
                filter: tab.key
            )

            return response.data.map { TicketUserContent($0) }
        }
    }
}
