//
//  SampleApp.swift
//  Sample
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

@main
final class SampleApp: ParraApp<ParraAppDelegate, ParraSceneDelegate> {
    // MARK: - Lifecycle

    required init() {
        super.init()

        configureParra(
            workspaceId: Parra.Demo.workspaceId,
            applicationId: Parra.Demo.applicationId,
            appContent: {
                ParraRequiredAuthView { _ in
                    ContentView()
                }
            }
        )
    }

    // MARK: - Internal

    /// An authentication provider to use when running in DEBUG mode. If you're
    /// working on integrating Parra into your app, this is generally the auth
    /// flow that you should be implementing for both DEBUG and RELEASE
    /// environments. This authentication method relies on an OAuth flow with
    /// your backend to create a Parra access token for a given user.
    func debugAuthenticationMethod() -> ParraAuthType {
        return .custom {
            let myAppAccessToken = Parra.Demo.demoUserId

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
    }

    /// An authentication provider used for the beta app for the Parra iOS SDK
    /// Demo. This app uses public key authentication, which is not preferred
    /// but provides an example of how it can be achieved and prevents the demo
    /// app from requiring a backend to authenticate with.
    func betaAuthenticationMethod() -> ParraAuthType {
        return .public(
            apiKeyId: Parra.Demo.apiKeyId,
            userIdProvider: {
                return Parra.Demo.demoUserId
            }
        )
    }

    func authenticationMethod() -> ParraAuthType {
        #if DEBUG
        return debugAuthenticationMethod()
        #else
        return betaAuthenticationMethod()
        #endif
    }
}
