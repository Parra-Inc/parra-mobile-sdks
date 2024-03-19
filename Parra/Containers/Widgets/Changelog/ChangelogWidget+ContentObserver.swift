//
//  ChangelogWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ReleaseType {
    var userFacingString: String {
        switch self {
        case .major:
            return "major"
        case .minor:
            return "minor"
        case .patch:
            return "patch"
        case .launch:
            return "launch"
        }
    }
}

struct AppReleaseStubContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    @MainActor
    init(
        _ stub: AppReleaseStub
    ) {
        self.originalStub = stub
        self.id = stub.id
        self.createdAt = LabelContent(
            text: stub.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.name = LabelContent(text: stub.name)
        self.version = LabelContent(text: stub.version)
        if let description = stub.description {
            self.description = LabelContent(text: description)
        } else {
            self.description = nil
        }
        self.type = LabelContent(text: stub.type.userFacingString)
        self.releaseNumber = LabelContent(text: String(stub.releaseNumber))
        self.status = stub.status
    }

    // MARK: - Internal

    let originalStub: AppReleaseStub
    let id: String
    let createdAt: LabelContent
    let name: LabelContent
    let version: LabelContent
    let description: LabelContent?
    let type: LabelContent
    let releaseNumber: LabelContent
    let status: ReleaseStatus
}

// MARK: - ChangelogWidget.ContentObserver

extension ChangelogWidget {
    @MainActor
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.networkManager = initialParams.networkManager
            let appReleaseCollection = initialParams.appReleaseCollection

            let emptyStateViewContent = EmptyStateContent(
                title: LabelContent(
                    text: "No new releases yet"
                ),
                subtitle: LabelContent(
                    text: "Stay tuned for future updates!"
                ),
                icon: .symbol("text.append")
            )

            let errorStateViewContent = EmptyStateContent(
                title: EmptyStateContent.errorGeneric.title,
                subtitle: LabelContent(
                    text: "Failed to load changelog. Please try again later."
                ),
                icon: .symbol("network.slash", .monochrome)
            )

            self.content = Content(
                title: "Releases",
                emptyStateView: emptyStateViewContent,
                errorStateView: errorStateViewContent
            )

            self.releasePaginator = .init(
                context: "",
                data: .init(
                    items: appReleaseCollection.data
                        .map { AppReleaseStubContent($0) },
                    placeholderItems: [],
                    pageSize: appReleaseCollection.pageSize,
                    knownCount: appReleaseCollection.totalCount
                ),
                pageFetcher: loadMoreReleases
            )
        }

        // MARK: - Internal

        @Published private(set) var content: Content

        // Using IUO because this object requires referencing self in a closure
        // in its init so we need all fields set. Post-init this should always
        // be set.
        @Published var releasePaginator: Paginator<
            AppReleaseStubContent,
            String
        >!

        let networkManager: ParraNetworkManager

        // MARK: - Private

        private func loadMoreReleases(
            _ limit: Int,
            _ offset: Int,
            _ ctx: String
        ) async throws -> [AppReleaseStubContent] {
            let response = try await networkManager.paginateReleases(
                limit: limit,
                offset: offset
            )

            return response.data.map { AppReleaseStubContent($0) }
        }
    }
}
