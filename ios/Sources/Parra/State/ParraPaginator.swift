//
//  ParraPaginator.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

public class ParraPaginator<Item, Context>: ObservableObject
    where Item: Identifiable & Hashable
{
    // MARK: - Lifecycle

    public convenience init(
        context: Context,
        data: Data,
        pageFetcher: NextPageFetcher?,
        missingFetcher: MissingPageFetcher? = nil
    ) {
        self.init(
            context: context,
            initialItems: data.items,
            placeholderItems: data.placeholderItems,
            pageSize: data.pageSize,
            totalCount: data.knownCount,
            pageFetcher: pageFetcher,
            missingFetcher: missingFetcher
        )
    }

    public init(
        context: Context,
        initialItems items: [Item],
        placeholderItems: [Item] = [],
        pageSize: Int,
        loadMoreThreshold: Int = 2,
        totalCount: Int? = nil,
        pageFetcher: NextPageFetcher?,
        missingFetcher: MissingPageFetcher? = nil
    ) {
        assert(loadMoreThreshold < pageSize)

        self.context = context
        self.pageSize = pageSize
        self.loadMoreThreshold = loadMoreThreshold
        self.totalCount = totalCount
        self.nextPageFetcher = pageFetcher
        self.missingPageFetcher = missingFetcher
        self.placeholderItems = placeholderItems
        self.isLoading = false
        self.isRefreshing = false
        self.lastFetchedOffset = nil

        if items.isEmpty {
            self.items = placeholderItems
            self.isShowingPlaceholders = true
        } else {
            self.items = items
            self.isShowingPlaceholders = false
        }
    }

    // MARK: - Public

    public struct Data: Equatable, Hashable {
        // MARK: - Lifecycle

        public init(
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

        // MARK: - Public

        public private(set) var items: [Item]
        public let placeholderItems: [Item]

        public let pageSize: Int

        /// The number of items that are known to exist, even if they all aren't
        /// in the items array yet. Can be nil if a fetch hasn't been performed
        /// yet with this data or the API didn't inform us how many of these
        /// records exist.
        public let knownCount: Int?

        public mutating func replacingItem(_ item: Item) -> Data {
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

    public typealias NextPageFetcher = (
        _ pageSize: Int,
        _ offset: Int,
        _ context: Context
    ) async throws -> [Item]

    public typealias MissingPageFetcher = (
        _ cursor: String?,
        _ context: Context
    ) async throws -> [Item]

    // Some arbitrary information to attach to the Paginator, which will be
    // passed to the PageFetcher func when it is invoked.
    public let context: Context

    public let loadMoreThreshold: Int
    public let pageSize: Int

    // If we haven't made the first request for these items, we don't know
    // this yet.
    public let totalCount: Int?

    // The last index that triggered fetching a page.
    public private(set) var lastFetchedOffset: Int?

    // If omitted, there will never be an attempt to load more content.
    public let nextPageFetcher: NextPageFetcher?

    // If omitted, there will be no attempts to load missing content.
    public let missingPageFetcher: MissingPageFetcher?

    @Published public var items: [Item]
    @Published public private(set) var isLoading: Bool
    @Published public private(set) var isRefreshing: Bool
    @Published public private(set) var error: Error?
    @Published public private(set) var isShowingPlaceholders: Bool

    @MainActor
    public func refresh() async {
        guard let nextPageFetcher else {
            return
        }

        guard !isRefreshing else {
            logger.trace("Already refreshing. Skipping refresh.")

            return
        }

        guard !isLoading else {
            logger.trace("Already loading. Skipping refresh.")

            return
        }

        logger.trace("Beginning refresh for \(context)")

        isRefreshing = true
        error = nil

        do {
            let nextPage = try await nextPageFetcher(pageSize, 0, context)

            await MainActor.run {
                lastFetchedOffset = 0
                items = nextPage
                isRefreshing = false
                isShowingPlaceholders = false
            }
        } catch {
            if !Task.isCancelled {
                logger.error("Error performing refresh", error)

                await MainActor.run {
                    self.error = error
                    items = []
                    isShowingPlaceholders = false
                    isRefreshing = false
                }
            }
        }
    }

    public func refresh() {
        Task { @MainActor in
            await refresh()
        }
    }

    @MainActor
    public func loadMissing(
        since cursor: String?
    ) async {
        guard let missingPageFetcher else {
            return
        }

        guard !isRefreshing else {
            logger.trace("Already refreshing. Skipping refresh.")

            return
        }

        guard !isLoading else {
            logger.trace("Already loading. Skipping refresh.")

            return
        }

        logger.trace("Beginning refresh for \(context)")

        isLoading = true
        error = nil

        do {
            let missingPage = try await missingPageFetcher(cursor, context)

            await MainActor.run {
                items.insert(contentsOf: missingPage, at: 0)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }

    public func loadMissing(
        since cursor: String?
    ) {
        Task { @MainActor in
            await loadMissing(since: cursor)
        }
    }

    public func loadMore(
        after index: Int?
    ) {
        guard let nextPageFetcher else {
            logger.trace("pageFetcher unset. Skipping load.")
            return
        }

        guard !isLoading else {
            logger.trace("Already loading. Skipping load.")
            return
        }

        guard !isRefreshing else {
            logger.trace("Already refreshing. Skipping load.")
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
                    "Fetching page size: \(self.pageSize) from offset: \(offset)."
                )

                let nextPage = try await nextPageFetcher(pageSize, offset, context)
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
                        logger.trace(
                            "Replacing placeholder items with fetched items"
                        )

                        items = nextPage
                        isShowingPlaceholders = false
                    } else {
                        logger.trace(
                            "Appending fetched items"
                        )

                        items.append(
                            contentsOf: nextPage.filter {
                                !items.contains($0)
                            }
                        )
                    }

                    isLoading = false
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

    public func removeItem(
        _ item: Item
    ) {
        removeItem(by: item.id)
    }

    public func removeItem(
        by id: Item.ID
    ) {
        // Must lookup by id instead of firstIndex(of:) because fields other
        // than `id` will change during the update.
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            logger.warn(
                "Attempt to delete item that did not previously exist.",
                [
                    "itemId": id,
                    "context": String(describing: context)
                ]
            )

            return
        }

        items.remove(at: index)
    }

    public func updateItem(
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

    public func moveItem(at fromIndex: Int, to index: Int) {
        if isShowingPlaceholders {
            return
        }

        guard index < items.count && index >= 0 else {
            return
        }

        items.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: index
        )
    }

    public func moveItem(_ item: Item, to index: Int) {
        if isShowingPlaceholders {
            return
        }

        guard let currentIndex = items.firstIndex(of: item) else {
            return
        }

        moveItem(at: currentIndex, to: index)
    }

    public func appendItem(_ item: Item) {
        if isShowingPlaceholders {
            return
        }

        items.append(item)
    }

    public func preppendItem(_ item: Item) {
        if isShowingPlaceholders {
            return
        }

        items.insert(item, at: 0)
    }

    public func replace(
        matching predicate: (Item) -> Bool,
        with newItem: Item
    ) {
        if isShowingPlaceholders {
            return
        }

        if let index = items.firstIndex(where: predicate) {
            items[index] = newItem
        }
    }

    public func replace(
        at index: Int,
        with newItem: Item
    ) {
        if isShowingPlaceholders {
            return
        }

        if index < items.count && index >= 0 {
            items[index] = newItem
        }
    }

    public func replace(_ item: Item, with newItem: Item) {
        if isShowingPlaceholders {
            return
        }

        if let index = items.firstIndex(of: item) {
            items[index] = newItem
        }
    }

    public func currentData() -> Data {
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

        if isShowingPlaceholders {
            return 0
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
        let next = index + loadMoreThreshold
        if next >= max {
            return nil
        }

        return next
    }
}
