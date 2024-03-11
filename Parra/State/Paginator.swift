//
//  Paginator.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@MainActor
class Paginator<Item, Context>: ObservableObject
    where Item: Identifiable & Hashable
{
    // MARK: - Lifecycle

    convenience init(
        context: Context,
        data: Data,
        pageFetcher: PageFetcher?
    ) {
        self.init(
            context: context,
            initialItems: data.items,
            placeholderItems: data.placeholderItems,
            pageSize: data.pageSize,
            totalCount: data.knownCount,
            pageFetcher: pageFetcher
        )
    }

    init(
        context: Context,
        initialItems items: [Item],
        placeholderItems: [Item] = [],
        pageSize: Int,
        loadMoreThreshold: Int = 2,
        totalCount: Int? = nil,
        pageFetcher: PageFetcher?
    ) {
        logger.trace("Initializing Paginator for context: \(context)")

        assert(loadMoreThreshold < pageSize)

        self.context = context
        self.pageSize = pageSize
        self.loadMoreThreshold = loadMoreThreshold
        self.totalCount = totalCount
        self.pageFetcher = pageFetcher
        self.placeholderItems = placeholderItems
        self.isLoading = false
        self.lastFetchedOffset = nil

        if items.isEmpty {
            self.items = placeholderItems
            self.isShowingPlaceholders = true

            loadMore(after: nil)
        } else {
            self.items = items
            self.isShowingPlaceholders = false
        }
    }

    // MARK: - Internal

    struct Data: Equatable, Hashable {
        // MARK: - Lifecycle

        init(
            items: [Item],
            placeholderItems: [Item] = [],
            pageSize: Int = 15,
            knownCount: Int? = nil
        ) {
            self.items = items
            self.placeholderItems = placeholderItems
            self.pageSize = pageSize
            self.knownCount = knownCount
        }

        // MARK: - Internal

        let items: [Item]
        let placeholderItems: [Item]

        let pageSize: Int

        /// The number of items that are known to exist, even if they all aren't
        /// in the items array yet. Can be nil if a fetch hasn't been performed
        /// yet with this data or the API didn't inform us how many of these
        /// records exist.
        let knownCount: Int?
    }

    typealias PageFetcher = (
        _ pageSize: Int,
        _ offset: Int,
        _ context: Context
    ) async throws -> [Item]

    // Some arbitrary information to attach to the Paginator, which will be
    // passed to the PageFetcher func when it is invoked.
    let context: Context

    let loadMoreThreshold: Int
    let pageSize: Int

    // If we haven't made the first request for these items, we don't know
    // this yet.
    let totalCount: Int?

    // The last index that triggered fetching a page.
    private(set) var lastFetchedOffset: Int?

    // If omitted, there will never be an attempt to load more content.
    let pageFetcher: PageFetcher?

    @Published private(set) var items: [Item]
    @Published private(set) var isLoading: Bool
    @Published private(set) var isShowingPlaceholders: Bool

    func loadMore(
        after index: Int?
    ) {
        guard let pageFetcher else {
            return
        }

        guard !isLoading else {
            return
        }

        guard let offset = getFetchOffset(for: index) else {
            return
        }

        logger.trace("Beginning load for \(context)")

        isLoading = true

        Task {
            // If we're loading more after an existing item, it implies that some
            // data has already been loaded. No item set means we're loading the
            // first page.
            do {
                logger.trace(
                    "Fetching page size: \(pageSize) from offset: \(offset)."
                )

                let nextPage = try await pageFetcher(pageSize, offset, context)
                logger.trace(
                    "Found \(nextPage.count) new record(s)"
                )

                // TODO: Store the ids of all items in a set along with their
                // indexes. Every time a new page is fetched, iterate over the
                // page and check if any of the ids previously existed. If they
                // do, perform a re-fetch of all the items from the first
                // duplicate to just before the fetch that just happened, and
                // replace that portion of the items list with the new data.
                // This handles the case where an item moves from one page to
                // another in between fetches.

                await MainActor.run {
                    // Should be set after successful load. Should be the index
                    // that triggered the request.
                    lastFetchedOffset = index

                    // If placeholders were previously shown they should be
                    // replaced.
                    if isShowingPlaceholders {
                        items = nextPage
                    } else {
                        items.append(contentsOf: nextPage)
                    }

                    isLoading = false
                    isShowingPlaceholders = false
                }
            } catch {
                logger.error("Pagination error fetching new record(s).", error)
            }
        }
    }

    func currentData() -> Data {
        return Data(
            items: items,
            placeholderItems: placeholderItems,
            pageSize: pageSize,
            knownCount: totalCount
        )
    }

    // MARK: - Private

    private let placeholderItems: [Item]

    private func getFetchOffset(for index: Int?) -> Int? {
        guard let index else {
            // Not fetching for a specific item, so either fetch the next page
            // after the last one, or start at the beginning.
            return lastFetchedOffset ?? 0
        }

        let last = lastFetchedOffset ?? -1
        let isPastThreshold = index >= items.count - loadMoreThreshold

        // We only want to fetch more records if
        // 1. The index that has triggered the request is past the threshold
        // 2. The index is higher then the previous load.
        guard isPastThreshold, index > last else {
            logger.trace(
                "Index not past threshold. \(isPastThreshold) \(index) \(last)"
            )

            return nil
        }

        logger.trace("Okay to fetch from: \(index)")
        // We determine if we want to load more if the current index reaches the
        // end of the list, less some threshold. When requesting more items, we
        // add this threshold back to not have `loadMoreThreshold` overlapping
        // items per request.
        return index + loadMoreThreshold
    }
}
