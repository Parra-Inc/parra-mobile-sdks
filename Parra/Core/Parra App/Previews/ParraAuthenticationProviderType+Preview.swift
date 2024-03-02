//
//  ParraAuthenticationProviderType+Preview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthenticationProviderType {
    nonisolated static let preview = ParraAuthenticationProviderType.default(
        tenantId: "4caab3fe-d0e7-4bc3-9d0a-4b36f32bd1b7",
        applicationId: "e9869122-fc90-4266-9da7-e5146d70deab",
        authProvider: {
            let myAppAccessToken = "9B5CDA6B-7538-4A2A-9611-7308D56DFFA1"

            var request = URLRequest(
                // Replace this with your Parra access token generation endpoint
                url: URL(
                    string: "http://localhost:8080/v1/parra/auth/token"
                )!
            )

            request.httpMethod = "POST"
            // Replace this with your app's way of authenticating users
            request.setValue(
                "Bearer \(myAppAccessToken)",
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