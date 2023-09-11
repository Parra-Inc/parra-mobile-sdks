//
//  Syncable.swift
//  Parra
//
//  Created by Mick MacCallum on 12/28/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol Syncable {
    func hasDataToSync(since date: Date?) async -> Bool
    func synchronizeData() async throws
}
