//
//  Parra+Changelogs.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    func fetchFeedbackForm(
        formId: String
    ) async throws -> ParraFeedbackForm {
        let response = try await networkManager.getFeedbackForm(with: formId)

        return ParraFeedbackForm(from: response)
    }
}
