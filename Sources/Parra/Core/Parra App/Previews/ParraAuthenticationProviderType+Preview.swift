//
//  ParraAuthenticationProviderType+Preview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAuthenticationProviderType {
    nonisolated static let preview = ParraAuthenticationProviderType.default(
        workspaceId: Parra.Demo.workspaceId,
        applicationId: Parra.Demo.applicationId,
        authProvider: {
            var request = URLRequest(
                // Replace this with your Parra access token generation endpoint
                url: URL(
                    string: "http://localhost:8080/v1/parra/auth/token"
                )!
            )

            request.httpMethod = "POST"
            // Replace this with your app's way of authenticating users
            request.setValue(
                "Bearer \(Parra.Demo.demoUserId)",
                forHTTPHeaderField: "Authorization"
            )

            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(
                [String: String].self,
                from: data
            )

            return response["access_token"]!
        }
    )
}
