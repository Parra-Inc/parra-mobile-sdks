//
//  Parra+Sync.swift
//  Parra
//
//  Created by Mick MacCallum on 4/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    // MARK: - Synchronization

    /// Parra data is syncrhonized automatically. Use this method if you wish to
    /// trigger a synchronization event manually. This may be something you want
    /// to do in response to a significant event in your app, or in response to
    /// a low memory warning, for example. Note that in order to prevent
    /// excessive network activity it may take up to 30 seconds for the sync to
    /// complete after being initiated.
    func triggerSync() async {
        await parraInternal.triggerSync()
    }
}
