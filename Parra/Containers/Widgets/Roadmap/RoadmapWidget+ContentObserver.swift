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

            let initialPaginator = Paginator<TicketContent, RoadmapWidget.Tab>(
                initialItems: ticketResponse.data.map {
                    TicketContent($0, delegate: self)
                },
                pageSize: ticketResponse.pageSize,
                totalCount: ticketResponse.totalCount,
                pageFetcher: loadMoreTickets
            )

            self.ticketPaginator = initialPaginator
            // Cache the initial tickets
            ticketCache[initialTab] = initialPaginator

            content.addRequestButton.onPress = addRequest
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        @Published private(set) var content: Content
        @Published private(set) var canAddRequests: Bool
        @Published private(set) var ticketPaginator: Paginator<
            TicketContent,
            RoadmapWidget.Tab
        > = .init(
            initialItems: [],
            totalCount: 0,
            pageFetcher: nil
        )

        @Published var addRequestForm: ParraFeedbackForm?

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
        private var ticketCache = [RoadmapWidget.Tab: Paginator<
            TicketContent,
            RoadmapWidget.Tab
        >]()

        private func tabWillChange(to newTab: Tab) {
            print("tab will change to: \(newTab)")

            if let cachedPaginator = ticketCache[newTab] {
                ticketPaginator = cachedPaginator
            } else {
                ticketPaginator = Paginator<TicketContent, RoadmapWidget.Tab>(
                    initialItems: [],
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

class Paginator<Item, Context>: ObservableObject
    where Item: Identifiable & Hashable
{
    // MARK: - Lifecycle

    init(
        initialItems: [Item],
        pageSize: Int = 15,
        loadMoreThreshold: Int = 2,
        totalCount: Int? = nil,
        pageFetcher: PageFetcher?
    ) {
        assert(loadMoreThreshold < pageSize)

        self.items = initialItems
        self.pageSize = pageSize
        self.loadMoreThreshold = loadMoreThreshold
        self.totalCount = totalCount
        self.pageFetcher = pageFetcher

        if !initialItems.isEmpty, pageFetcher != nil {
            loadMore(after: nil)
        }
    }

    // MARK: - Internal

    typealias PageFetcher = (
        _ pageSize: Int,
        _ offset: Int,
        _ context: Context
    ) async throws -> [Item]

    let loadMoreThreshold: Int
    let pageSize: Int

    // If we haven't made the first request for these items, we don't know
    // this yet.
    let totalCount: Int?

    // If omitted, there will never be an attempt to load more content.
    let pageFetcher: PageFetcher?

    // TODO: Start task to refresh the tickets?

    @Published private(set) var items: [Item]
    @Published private(set) var isLoading: Bool = false

    func loadMore(
        after item: Item?
    ) {
        guard let pageFetcher else {
            return
        }

//        let offset: Int =

        let thresholdIndex = items.index(
            items.endIndex,
            offsetBy: -loadMoreThreshold
        )

//        items[thresholdIndex]

        //                tickets = (0...15).map { _ in TicketContent.redacted }

//        thresholdIndex

//        if thresholdIndex == item.id, (page + 1) <= totalPages {
//            //                page += 1
//            //                getUsers()
//        }
    }
}
