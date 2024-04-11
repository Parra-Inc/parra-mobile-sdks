//
//  AuthenticationService.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

final class AuthenticationService {
    // MARK: - Lifecycle

    init(oauth2Service: OAuth2Service) {
        self.oauth2Service = oauth2Service
    }

    // MARK: - Internal

    let oauth2Service: OAuth2Service
}

// API

// resource -> parra api
// auth server
