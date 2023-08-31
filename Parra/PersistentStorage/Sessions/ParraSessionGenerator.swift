//
//  ParraSessionGenerator.swift
//  Parra
//
//  Created by Mick MacCallum on 8/13/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

fileprivate let logger = Logger(category: "Session Upload Generator")

internal struct ParraSessionGenerator: AsyncSequence, AsyncIteratorProtocol {
    // Type is optional. We have to be able to filter out elements while doing the lazy enumeration
    // so we need a way to indicate to the caller that the item produced by a given iteration can
    // be skipped, whichout returning nil and ending the Sequence. We use a double Optional for this.
    typealias Element = ParraSessionUpload?

    private let directoryEnumerator: FileManager.DirectoryEnumerator
    private let jsonDecoder: JSONDecoder
    private let currentSessionDirectory: URL?
    private let fileManager = FileManager.default

    internal init(
        directoryEnumerator: FileManager.DirectoryEnumerator,
        jsonDecoder: JSONDecoder,
        currentSessionDirectory: URL?
    ) {
        self.directoryEnumerator = directoryEnumerator
        self.jsonDecoder = jsonDecoder
        self.currentSessionDirectory = currentSessionDirectory
    }

    mutating func next() async -> Element? {
        return await logger.withScope { logger in
            guard let nextSessionUrl = directoryEnumerator.nextObject() as? URL else {
                logger.debug("next session url couldn't be produced")

                return nil
            }

            if !nextSessionUrl.hasDirectoryPath || nextSessionUrl.pathExtension != ParraSession.Constant.packageExtension {
                logger.debug("session path was unexpected file type. skipping.")
                // This is a case where we're indicating an invalid item was produced, and it is necessary to skip it.
                return .some(.none)
            }

            do {
                logger.trace("combining data for session: \(nextSessionUrl.lastPathComponent)")

                let (sessionPath, eventsPath) = SessionReader.sessionPaths(in: nextSessionUrl)

                let session = try readSessionSync(at: sessionPath)
                let events = try await readEvents(at: eventsPath)

                logger.trace("finished reading session and events")

                return ParraSessionUpload(
                    session: session,
                    events: events
                )
            } catch let error {
                logger.error("Error creating upload payload for session", error, [
                    "path": nextSessionUrl.lastComponents()
                ])

                return .some(.none)
            }
        }
    }

    func makeAsyncIterator() -> ParraSessionGenerator {
        self
    }

    private func readSessionSync(at path: URL) throws -> ParraSession {
        let fileHandle = try FileHandle(forReadingFrom: path)

        guard let sessionData = try fileHandle.readToEnd() else {
            throw ParraError.fileSystem(
                path: path,
                message: "Couldn't read session data"
            )
        }

        try fileHandle.close()

        return try jsonDecoder.decode(ParraSession.self, from: sessionData)
    }

    private func readEvents(at path: URL) async throws -> [ParraSessionEvent] {
        var events = [ParraSessionEvent]()
        let fileHandle = try FileHandle(forReadingFrom: path)

        for try await eventString in fileHandle.bytes.lines {
            // As every row is parsed, place it in an events array. This will save us have two copies
            // of every event in memory at the same time.
            try autoreleasepool {
                if let eventData = eventString.data(using: .utf8) {
                    events.append(
                        try jsonDecoder.decode(ParraSessionEvent.self, from: eventData)
                    )
                }
            }
        }

        try fileHandle.close()

        return events
    }
}
