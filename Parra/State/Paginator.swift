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

        private(set) var items: [Item]
        let placeholderItems: [Item]

        let pageSize: Int

        /// The number of items that are known to exist, even if they all aren't
        /// in the items array yet. Can be nil if a fetch hasn't been performed
        /// yet with this data or the API didn't inform us how many of these
        /// records exist.
        let knownCount: Int?

        mutating func replacingItem(_ item: Item) -> Data {
            var next = self

            guard let index = next.items.firstIndex(
                where: { $0.id == item.id }
            ) else {
                return next
            }

            next.items[index] = item

            return next
        }
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

    @Published var items: [Item]
    @Published private(set) var isLoading: Bool
    @Published private(set) var error: Error?
    @Published private(set) var isShowingPlaceholders: Bool

    @MainActor
    func refresh() async {
        guard let pageFetcher else {
            return
        }

        guard !isLoading else {
            return
        }

        logger.trace("Beginning refresh for \(context)")

        isLoading = true
        error = nil

        do {
            let nextPage = try await pageFetcher(pageSize, 0, context)

            await MainActor.run {
                lastFetchedOffset = 0
                items = nextPage
                isLoading = false
                isShowingPlaceholders = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                items = []
                isShowingPlaceholders = false
                isLoading = false
            }
        }
    }

    @MainActor
    func loadMore(
        after index: Int?
    ) {
        guard let pageFetcher else {
            logger.trace("pageFetcher unset. Skipping load.")
            return
        }

        guard !isLoading else {
            logger.trace("Already loading. Skipping load.")
            return
        }

        guard let offset = getFetchOffset(for: index) else {
            logger.trace("No next offset found. Skipping load.")

            return
        }

        logger.trace("Beginning load for \(context)")

        isLoading = true
        error = nil

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

                await MainActor.run {
                    isLoading = false

                    // There was already some data, so don't hide it to show an
                    // error view.
                    if isShowingPlaceholders {
                        isShowingPlaceholders = false
                        items = []

                        self.error = error
                    }
                }
            }
        }
    }

    @MainActor
    func updateItem(
        _ item: Item
    ) {
        // Must lookup by id instead of firstIndex(of:) because fields other
        // than `id` will change during the update.
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            logger.warn(
                "Attempt to update item that did not previously exist.",
                [
                    "itemId": item.id,
                    "context": String(describing: context)
                ]
            )

            return
        }

        items[index] = item
    }

    @MainActor
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

        let max = totalCount ?? Int.max

        guard index < (max - 1) else {
            logger.trace("Index has reached totalCount: \(max). Skipping fetch")

            return nil
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
