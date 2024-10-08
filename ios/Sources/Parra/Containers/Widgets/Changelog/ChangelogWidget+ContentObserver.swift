//
//  ChangelogWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Combine
import SwiftUI

struct AppReleaseStubContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init(
        _ stub: AppReleaseStub
    ) {
        self.originalStub = stub
        self.id = stub.id
        self.createdAt = ParraLabelContent(
            text: stub.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.name = ParraLabelContent(text: stub.name)
        self.version = ParraLabelContent(text: stub.version)
        if let description = stub.description {
            self.description = ParraLabelContent(text: description)
        } else {
            self.description = nil
        }
        if let type = stub.type.value {
            self.type = ParraLabelContent(text: type.userFacingString)
        } else {
            self.type = nil
        }

        self.releaseNumber = ParraLabelContent(text: String(stub.releaseNumber))
        self.status = stub.status.value
    }

    // MARK: - Internal

    static var redacted: AppReleaseStubContent {
        return AppReleaseStubContent(AppReleaseStub.validStates()[0])
    }

    let originalStub: AppReleaseStub
    let id: String
    let createdAt: ParraLabelContent
    let name: ParraLabelContent
    let version: ParraLabelContent
    let description: ParraLabelContent?
    let type: ParraLabelContent?
    let releaseNumber: ParraLabelContent
    let status: ParraReleaseStatus?
}

// MARK: - ChangelogWidget.ContentObserver

extension ChangelogWidget {
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.api = initialParams.api
            let appReleaseCollection = initialParams.appReleaseCollection

            let emptyStateViewContent = ParraEmptyStateContent(
                title: ParraLabelContent(
                    text: "No new releases yet"
                ),
                subtitle: ParraLabelContent(
                    text: "Stay tuned for future updates!"
                ),
                icon: .symbol("text.append")
            )

            let errorStateViewContent = ParraEmptyStateContent(
                title: ParraEmptyStateContent.errorGeneric.title,
                subtitle: ParraLabelContent(
                    text: "Failed to load changelog. Please try again later."
                ),
                icon: .symbol("network.slash", .monochrome)
            )

            self.content = Content(
                title: "Releases",
                emptyStateView: emptyStateViewContent,
                errorStateView: errorStateViewContent
            )

            self.releasePaginator = if let appReleaseCollection {
                .init(
                    context: "",
                    data: .init(
                        items: appReleaseCollection.data.elements
                            .map { AppReleaseStubContent($0) },
                        placeholderItems: [],
                        pageSize: appReleaseCollection.pageSize,
                        knownCount: appReleaseCollection.totalCount
                    ),
                    pageFetcher: loadMoreReleases
                )
            } else {
                .init(
                    context: "",
                    data: .init(
                        items: [],
                        placeholderItems: (0 ... 15)
                            .map { _ in AppReleaseStubContent.redacted }
                    ),
                    pageFetcher: loadMoreReleases
                )
            }
        }

        // MARK: - Internal

        @Published private(set) var content: Content

        let api: API

        // Using IUO because this object requires referencing self in a closure
        // in its init so we need all fields set. Post-init this should always
        // be set.
        @Published var releasePaginator: ParraPaginator<
            AppReleaseStubContent,
            String
        >! {
            willSet {
                paginatorSink?.cancel()
                paginatorSink = nil
            }

            didSet {
                paginatorSink = releasePaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
            }
        }

        @MainActor
        func loadInitialReleases() {
            releasePaginator.loadMore(after: nil)
        }

        // MARK: - Private

        private var paginatorSink: AnyCancellable? = nil

        private func loadMoreReleases(
            _ limit: Int,
            _ offset: Int,
            _ ctx: String
        ) async throws -> [AppReleaseStubContent] {
            Logger.trace("Loading more releases", [
                "limit": String(limit),
                "offset": String(offset),
                "ctx": ctx
            ])

            let response = try await api.paginateReleases(
                limit: limit,
                offset: offset
            )

            return response.data.elements.map { AppReleaseStubContent($0) }
        }
    }
}
