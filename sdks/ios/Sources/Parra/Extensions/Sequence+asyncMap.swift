//
//  Sequence+asyncMap.swift
//  Parra
//
//  Created by Mick MacCallum on 10/15/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
