//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {
    /// Checks whether an authentication provider has already been set.
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }

    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as early as possible
    /// inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's access token.
    ///   This function will be invoked automatically whenever the user's credential is missing or expired and Parra needs to refresh
    ///   the authentication state for your user.
    class func initialize(config: ParraConfiguration = .default,
                          authProvider: ParraAuthenticationProvider) {

        shared.networkManager.updateAuthenticationProvider(authProvider.retreiveCredential)

        Task {
            do {
                let _ = try await shared.networkManager.refreshAuthentication()
            } catch let error {
                parraLogE("Refresh authentication on user change: \(error)")
            }
        }
    }
}
