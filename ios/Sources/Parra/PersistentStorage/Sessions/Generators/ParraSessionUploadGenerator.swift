//
//  ParraSessionUploadGenerator.swift
//  Parra
//
//  Created by Mick MacCallum on 8/13/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(
    bypassEventCreation: true,
    category: "Session Upload Generator"
)

enum ParraSessionUploadGeneratorElement {
    case success(sessionDirectory: URL, upload: ParraSessionUpload)
    case error(sessionDirectory: URL, error: ParraError)
}

struct ParraSessionUploadGenerator: ParraSessionGeneratorType, AsyncSequence,
    AsyncIteratorProtocol
{
    // MARK: - Lifecycle

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

    // MARK: - Internal

    typealias Element = ParraSessionUploadGeneratorElement

    let sessionJsonDecoder: JSONDecoder
    let eventJsonDecoder: JSONDecoder
    let fileManager: FileManager

    mutating func next() async -> ParraSessionUploadGeneratorElement? {
        return await logger
            .withScope { logger -> ParraSessionUploadGeneratorElement? in
                guard let element = produceNextSessionPaths(
                    from: directoryEnumerator,
                    type: ParraSessionUpload.self
                ) else {
                    return nil
                }

                switch element {
                case .success(
                    let sessionDirectory,
                    let sessionPath,
                    let eventsPath
                ):
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
                    } catch {
                        return .error(
                            sessionDirectory: sessionDirectory,
                            error: .generic(
                                "Error creating upload payload for session",
                                error
                            )
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

    // MARK: - Private

    private let directoryEnumerator: FileManager.DirectoryEnumerator
}
