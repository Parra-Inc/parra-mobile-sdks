//
//  Task+sleep.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal extension Task where Success == Never, Failure == Never {
    static func sleep(ms: Int) async throws {
        let duration = UInt64(ms * 1_000_000)
        try await Task.sleep(nanoseconds: duration)
    }

    static func sleep(for timeInterval: TimeInterval) async throws {
        let duration = UInt64(timeInterval * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
