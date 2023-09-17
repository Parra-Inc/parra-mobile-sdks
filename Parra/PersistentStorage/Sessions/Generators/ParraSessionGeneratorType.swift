//
//  ParraSessionGeneratorType.swift
//  Parra
//
//  Created by Mick MacCallum on 8/31/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

fileprivate let logger = Logger(
    bypassEventCreation: true,
    category: "Session Generator Helpers"
)

internal enum ParraSessionGeneratorTypeElement {
    case success(sessionDirectory: URL, sessionPath: URL, eventsUrl: URL)
    case error(sessionDirectory: URL, error: ParraError)
}

internal protocol ParraSessionGeneratorType {
    var jsonDecoder: JSONDecoder { get }
    var fileManager: FileManager { get }
}

internal extension ParraSessionGeneratorType where Self: AsyncSequence {
    func makeAsyncIterator() -> Self {
        self
    }
}

internal extension ParraSessionGeneratorType {
    static func directoryEnumerator(
        forSessionsAt path: URL,
        with fileManager: FileManager
    ) throws -> FileManager.DirectoryEnumerator {
        guard let directoryEnumerator = fileManager.enumerator(
            at: path,
            includingPropertiesForKeys: [],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            throw ParraError.fileSystem(
                path: path,
                message: "Failed to create file enumerator"
            )
        }

        return directoryEnumerator
    }

    func produceNextSessionPaths<T>(
        from directoryEnumerator: FileManager.DirectoryEnumerator,
        type: T.Type
    ) -> ParraSessionGeneratorTypeElement? {
        return logger.withScope { logger in
            guard let nextSessionUrl = directoryEnumerator.nextObject() as? URL else {
                logger.debug("next session url couldn't be produced")

                return nil
            }

            let ext = ParraSession.Constant.packageExtension
            if !nextSessionUrl.hasDirectoryPath || nextSessionUrl.pathExtension != ext {
                logger.debug("session path was unexpected file type. skipping.")

                // This is a case where we're indicating an invalid item was produced, and it is necessary to skip it.
                return .error(
                    sessionDirectory: nextSessionUrl,
                    error: .fileSystem(
                        path: nextSessionUrl,
                        message: "Session directory was not valid."
                    )
                )
            }

            logger.trace("combining data for session: \(nextSessionUrl.lastPathComponent)")

            let (sessionPath, eventsUrl) = SessionReader.sessionPaths(
                in: nextSessionUrl
            )

            return .success(
                sessionDirectory: nextSessionUrl,
                sessionPath: sessionPath,
                eventsUrl: eventsUrl
            )
        }
    }

    func readSessionSync(at path: URL) throws -> ParraSession {
        let fileHandle = try FileHandle(forReadingFrom: path)
        try fileHandle.seek(toOffset: 0)

        guard let sessionData = try fileHandle.readToEnd() else {
            throw ParraError.fileSystem(
                path: path,
                message: "Couldn't read session data"
            )
        }

        try fileHandle.close()

        return try jsonDecoder.decode(ParraSession.self, from: sessionData)
    }

    func readEvents(at path: URL) async throws -> [ParraSessionEvent] {
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
