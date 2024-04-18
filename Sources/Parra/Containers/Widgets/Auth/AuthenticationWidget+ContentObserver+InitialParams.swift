//
//  AuthenticationWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthenticationWidget.ContentObserver {
    struct InitialParams {
        let error: Error?
        let authService: AuthService
        let methods: [ParraAuthMethod]
    }
}
