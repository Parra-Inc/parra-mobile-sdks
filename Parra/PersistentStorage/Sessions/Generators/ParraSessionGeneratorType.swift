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
    var sessionJsonDecoder: JSONDecoder { get }
    var eventJsonDecoder: JSONDecoder { get }
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
        
        defer {
            do {
                try fileHandle.close()
            } catch let error {
                logger.error("Error closing session reader file handle", error)
            }
        }

        try fileHandle.seek(toOffset: 0)

        let sessionData: Data?
        do {
            sessionData = try fileHandle.readToEnd()
        } catch let error {
            throw ParraError.fileSystem(
                path: path,
                message: "Couldn't read session data. \(error.localizedDescription)"
            )
        }

        guard let sessionData else {
            throw ParraError.fileSystem(
                path: path,
                message: "Session file was empty."
            )
        }

        return try sessionJsonDecoder.decode(
            ParraSession.self,
            from: sessionData
        )
    }

    func readEvents(at path: URL) async throws -> [ParraSessionEvent] {
        var events = [ParraSessionEvent]()
        let fileHandle = try FileHandle(forReadingFrom: path)
     
        defer {
            do {
                try fileHandle.close()
            } catch let error {
                logger.error("Error closing event reader file handle", error)
            }
        }

        for try await eventString in fileHandle.bytes.lines {
            // As every row is parsed, place it in an events array. This will save us have two copies
            // of every event in memory at the same time.
            try autoreleasepool {
                if let eventData = eventString.data(using: .utf8) {
                    events.append(
                        try eventJsonDecoder.decode(
                            ParraSessionEvent.self,
                            from: eventData
                        )
                    )
                }
            }
        }

        return events
    }
}
