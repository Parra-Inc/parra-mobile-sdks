//
//  ParraSessionGenerator.swift
//  Parra
//
//  Created by Mick MacCallum on 8/31/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(
    bypassEventCreation: true,
    category: "Session Generator"
)

enum ParraSessionGeneratorElement {
    case success(sessionDirectory: URL, session: ParraSession)
    case error(sessionDirectory: URL, error: ParraError)
}

struct ParraSessionGenerator: ParraSessionGeneratorType, Sequence,
    IteratorProtocol
{
    // MARK: Lifecycle

    init(
        forSessionsAt path: URL,
        sessionJsonDecoder: JSONDecoder,
        eventJsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) throws {
        self.sessionJsonDecoder = sessionJsonDecoder
        self.eventJsonDecoder = eventJsonDecoder
        self.fileManager = fileManager
        self.directoryEnumerator = try Self.directoryEnumerator(
            forSessionsAt: path,
            with: fileManager
        )
    }

    // MARK: Internal

    // Type is optional. We have to be able to filter out elements while doing the lazy enumeration
    // so we need a way to indicate to the caller that the item produced by a given iteration can
    // be skipped, whichout returning nil and ending the Sequence. We use a double Optional for this.
    typealias Element = ParraSessionGeneratorElement

    let sessionJsonDecoder: JSONDecoder
    let eventJsonDecoder: JSONDecoder
    let fileManager: FileManager

    mutating func next() -> ParraSessionGeneratorElement? {
        return logger.withScope { _ -> ParraSessionGeneratorElement? in
            guard let element = produceNextSessionPaths(
                from: directoryEnumerator,
                type: ParraSession.self
            ) else {
                return nil
            }

            switch element {
            case .success(let sessionDirectory, let sessionPath, _):
                do {
                    return try .success(
                        sessionDirectory: sessionDirectory,
                        session: readSessionSync(at: sessionPath)
                    )
                } catch {
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

    // MARK: Private

    private let directoryEnumerator: FileManager.DirectoryEnumerator
}
