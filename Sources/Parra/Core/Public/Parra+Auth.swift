//
//  Parra+Auth.swift
//  Parra
//
//  Created by Mick MacCallum on 4/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    // MARK: - Authentication

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    func logout() async {
        await parraInternal.syncManager.enqueueSync(with: .immediate)
        await parraInternal.syncManager.stopSyncTimer()
        await parraInternal.authService.logout()
    }

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    func logout(_ completion: (() -> Void)? = nil) {
        Task {
            await logout()
            completion?()
        }
    }
}
