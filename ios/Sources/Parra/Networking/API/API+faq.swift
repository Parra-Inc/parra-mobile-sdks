//
//  API+faq.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import Foundation

extension API {
    func getFAQLayout() async throws -> ParraAppFaqLayout {
        return try await hitEndpoint(
            .getFaqs,
            cachePolicy: .init(.reloadRevalidatingCacheData)
        )
    }
}
