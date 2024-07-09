//
//  ParraRoadmap.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "Roadmap Mobile")

public final class ParraRoadmap {
    // MARK: - Lifecycle

    init(
        api: API,
        apiResourceServer: ApiResourceServer
    ) {
        self.api = api
        self.apiResourceServer = apiResourceServer
    }

    // MARK: - Public

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

                guard let tab = roadmapConfig.tabs.first else {
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

                let roadmapInfo = ParraRoadmapInfo(
                    roadmapConfig: roadmapConfig,
                    selectedTab: tab,
                    ticketResponse: ticketResponse
                )

                DispatchQueue.main.async {
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
}
