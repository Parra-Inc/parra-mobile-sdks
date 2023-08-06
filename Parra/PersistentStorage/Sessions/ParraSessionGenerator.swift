//
//  ParraSessionGenerator.swift
//  Parra
//
//  Created by Mick MacCallum on 8/13/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSessionGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = ParraSessionUpload

    private var pathIterator: IndexingIterator<[URL]>
    private let fileManager = FileManager.default

    internal init(paths: [URL]) {
        pathIterator = paths.makeIterator()
    }

    mutating func next() async -> Element? {
        guard let nextPath = pathIterator.next() else {
            return nil
        }

        //        if current < 0 {
        //            return nil
        //        } else {
        //            return current
        //        }

        return nil
    }

    func makeAsyncIterator() -> ParraSessionGenerator {
        self
    }
}
