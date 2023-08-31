//
//  ParraSessionGenerator.swift
//  Parra
//
//  Created by Mick MacCallum on 8/31/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

fileprivate let logger = Logger(
    bypassEventCreation: true,
    category: "Session Generator"
)

internal struct ParraSessionGenerator: ParraSessionGeneratorType, AsyncSequence, AsyncIteratorProtocol {
    // Type is optional. We have to be able to filter out elements while doing the lazy enumeration
    // so we need a way to indicate to the caller that the item produced by a given iteration can
    // be skipped, whichout returning nil and ending the Sequence. We use a double Optional for this.
    typealias Element = ParraSession?

    private let directoryEnumerator: FileManager.DirectoryEnumerator

    let jsonDecoder: JSONDecoder
    let fileManager: FileManager

    internal init(
        forSessionsAt path: URL,
        jsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) throws {
        self.jsonDecoder = jsonDecoder
        self.fileManager = fileManager
        self.directoryEnumerator = try Self.directoryEnumerator(
            forSessionsAt: path,
            with: fileManager
        )
    }

    mutating func next() async -> Element? {
        return logger.withScope { logger in
            let (sessionPaths, optionality) = produceNextSessionPaths(
                from: directoryEnumerator,
                type: ParraSession.self
            )

            guard let sessionPaths else {
                return optionality
            }

            let (sessionPath, _) = sessionPaths

            do {
                return try readSessionSync(at: sessionPath)
            } catch let error {
                logger.error("Error reading session", error, [
                    "path": sessionPath.lastComponents()
                ])

                return .some(.none)
            }
        }
    }
}
