//
//  Task.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Task where Success == Never, Failure == Never {
    static func sleep(ms: Int) async throws {
        let duration = UInt64(ms * 1_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
