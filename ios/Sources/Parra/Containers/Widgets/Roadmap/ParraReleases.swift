//
//  ParraReleases.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "Roadmap Mobile")

public final class ParraReleases {
    // MARK: - Lifecycle

    init(
        api: API,
        apiResourceServer: ApiResourceServer,
        appInfoManager: AppInfoManager
    ) {
        self.api = api
        self.apiResourceServer = apiResourceServer
        self.appInfoManager = appInfoManager
    }

    // MARK: - Public

    // MARK: - What's New?

    /// Fetches information about the most recent release of your app from
    /// Parra. This information can be used to render custom UI, or with Parra's
    /// ``SwiftUI/View/presentParraReleaseWidget(with:config:onDismiss:)``
    /// modifier to present a sheet showing off the details of the release.
    public func fetchLatestRelease() async throws -> ParraNewInstalledVersionInfo? {
        let appInfo = try await appInfoManager.fetchLatestAppInfo(
            force: true
        )

        return appInfo.newInstalledVersionInfo
    }

    /// Whether a newer version of the app is available. In DEBUG mode this
    /// always returns true.
    public func updateAvailable() -> Bool {
        #if DEBUG
        return true
        #else
        return appInfoManager.isAwareOfNewerRelease
        #endif
    }

    // MARK: - Changelog

    public func fetchChangelog() async throws -> ParraChangelogInfo? {
        let params = ChangelogParams(
            limit: 15,
            offset: 0
        )

        let response = try await api.paginateReleases(
            limit: params.limit,
            offset: params.offset
        )

        if response.data.elements.isEmpty {
            return nil
        }

        return ParraChangelogInfo(
            appReleaseCollection: response
        )
    }

    // MARK: - Roadmap

    public func fetchRoadmap() async throws -> ParraRoadmapInfo {
        return try await withCheckedThrowingContinuation { continuation in
            fetchRoadmap { result in
                continuation.resume(with: result)
            }
        }
    }

    public func fetchRoadmap(
        withCompletion completion: @escaping (
            Result<ParraRoadmapInfo, ParraError>
        ) -> Void
    ) {
        Task {
            do {
                let roadmapConfig = try await api.getRoadmap()

                guard let tab = roadmapConfig.tabs.elements.first else {
                    throw ParraError.message(
                        "Can not paginate tickets. Roadmap response has no tabs."
                    )
                }

                let transformParams = RoadmapParams(
                    limit: 15,
                    offset: 0
                )

                let ticketResponse = try await api.paginateTickets(
                    limit: transformParams.limit,
                    offset: transformParams.offset,
                    filter: tab.key
                )

                Task { @MainActor in
                    let roadmapInfo = ParraRoadmapInfo(
                        roadmapConfig: roadmapConfig,
                        selectedTab: tab,
                        ticketResponse: ticketResponse
                    )

                    completion(.success(roadmapInfo))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(
                        .failure(ParraError.generic(
                            "Error fetching Parra Roadmap",
                            error
                        ))
                    )
                }
            }
        }
    }

    // MARK: - Internal

    let api: API
    let apiResourceServer: ApiResourceServer
    let appInfoManager: AppInfoManager
}
