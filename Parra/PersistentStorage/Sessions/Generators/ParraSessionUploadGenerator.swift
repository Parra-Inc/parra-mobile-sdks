//
//  ParraSessionUploadGenerator.swift
//  Parra
//
//  Created by Mick MacCallum on 8/13/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

fileprivate let logger = Logger(bypassEventCreation: true, category: "Session Upload Generator")

internal enum ParraSessionUploadGeneratorElement {
    case success(sessionDirectory: URL, upload: ParraSessionUpload)
    case error(sessionDirectory: URL, error: ParraError)
}

internal struct ParraSessionUploadGenerator: ParraSessionGeneratorType, AsyncSequence, AsyncIteratorProtocol {
    typealias Element = ParraSessionUploadGeneratorElement

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

    mutating func next() async -> ParraSessionUploadGeneratorElement? {
        return await logger.withScope { (logger) -> ParraSessionUploadGeneratorElement? in
            guard let element = produceNextSessionPaths(
                from: directoryEnumerator,
                type: ParraSessionUpload.self
            ) else {
                return nil
            }

            switch element {
            case .success(let sessionDirectory, let sessionPath, let eventsPath):
                do {
                    let session = try readSessionSync(at: sessionPath)
                    let events = try await readEvents(at: eventsPath)

                    logger.trace("Finished reading session and events", [
                        "sessionId": session.sessionId,
                        "eventCount": events.count
                    ])

                    return .success(
                        sessionDirectory: sessionDirectory,
                        upload: ParraSessionUpload(
                            session: session,
                            events: events
                        )
                    )
                } catch let error {
                    return .error(
                        sessionDirectory: sessionDirectory,
                        error: .generic("Error creating upload payload for session", error)
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
