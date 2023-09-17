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

internal enum ParraSessionGeneratorElement {
    case success(sessionDirectory: URL, session: ParraSession)
    case error(sessionDirectory: URL, error: ParraError)
}

internal struct ParraSessionGenerator: ParraSessionGeneratorType, Sequence, IteratorProtocol {
    // Type is optional. We have to be able to filter out elements while doing the lazy enumeration
    // so we need a way to indicate to the caller that the item produced by a given iteration can
    // be skipped, whichout returning nil and ending the Sequence. We use a double Optional for this.
    typealias Element = ParraSessionGeneratorElement

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

    mutating func next() -> ParraSessionGeneratorElement? {
        return logger.withScope { (logger) -> ParraSessionGeneratorElement? in
            guard let element = produceNextSessionPaths(
                from: directoryEnumerator,
                type: ParraSession.self
            ) else {
                return nil
            }

            switch element {
            case .success(let sessionDirectory, let sessionPath, _):
                do {
                    return .success(
                        sessionDirectory: sessionDirectory,
                        session: try readSessionSync(at: sessionPath)
                    )
                } catch let error {
                    return .error(
                        sessionDirectory: sessionDirectory,
                        error: .generic("Error reading session", error)
                    )
                }
            case .error(let sessionDirectory, let error):
                return .error(
                    sessionDirectory: sessionDirectory,
                    error: error
                )
            }
        }
    }
}
