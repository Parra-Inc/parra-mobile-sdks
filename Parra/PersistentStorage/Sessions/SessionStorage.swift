//
//  SessionStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 11/20/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

// TODO: !!!!!!!!!!!!!!!!!!!! need to actually use the completion handlers
// on all the with.... calls to make sure errors being thrown doesn't cause them to sometimes
// go uncalled.

import Foundation

// Should be able to:
// 1. Open a file handle when a session is started
// 2. Close the handle when the app resigns active and re-open it on foreground
// 3. Handle auto re-opening the handle if an event is added and the handle is closed
// 4. Write new events to disk as they come in. If a write is in progress
//    queue them and flush them when the write finishes.
// 5. Should support optionally waiting for a write to complete.
// 6. Store session data in a seperate file from the events list.
// 7. Provide a way to get all the sessions without their events
// 8. Provide a way to delete all the sessions and their events

// 7 and 8 so we can refactor bulk session submission to load then upload
// one at a time instead of loading all then uploading one at a time.

fileprivate let logger = Logger(bypassEventCreation: true, category: "Session Storage")

/// Handles underlying storage of sessions and events. The general approach that is taken is
/// to store a session object with id, user properties, etc and seperately store a list of events.
/// The file where events are written to will have a file handle held open to allow immediate writing
/// of single events. All of the internal work done within this class requires the use of serial queues.
/// async will only be used within this class to provide conveinence methods that are accessed externally.
internal class SessionStorage {
    private struct Constant {
        static let newlineCharData = "\n".data(using: .utf8)!
    }

    fileprivate let storageQueue = DispatchQueue(
        label: "com.parra.sessions.session-storage",
        qos: .utility
    )

    private var isInitialized = false

    private let sessionReader: SessionReader
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    internal init(
        sessionReader: SessionReader,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.sessionReader = sessionReader
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    deinit {
        logger.trace("deinit")

        do {
            try sessionReader.closeCurrentSessionSync()
        } catch let error {
            logger.error("Error closing session reader/file handles", error)
        }
    }

    internal func initializeSessions() async {
        logger.debug("initializing at path: \(sessionReader.basePath.safeNonEncodedPath())")

        // Attempting to access the current session will force the session reader to load
        // or create one, if one doesn't exist. Since this is only called during app launch,
        // it will always create a new session, which we will turn around and persist immediately,
        // as this is a requirement for the session to be considered initialized. If this method
        // is mistakenly called multiple times, this will also ensure that the existing session
        // will be used.
        await withCheckedContinuation { continuation in
            withCurrentSessionHandle { handle, session in
                try self.writeSessionSync(
                    session: session,
                    with: handle
                )
            } completion: { error in
                if let error {
                    logger.error("Error initializing session", error)
                }

                continuation.resume()
            }
        }
    }

    internal func getCurrentSession() async -> ParraSession {
        return await withCheckedContinuation { continuation in
            getCurrentSessionSync { session in
                continuation.resume(returning: session)
            }
        }
    }

    private func getCurrentSessionSync(
        completion: @escaping (ParraSession) -> Void
    ) {
        withCurrentSessionHandle { _, session in
            completion(session)
        }
    }

    // MARK: Updating Sessions

    internal func writeUserPropertyUpdate(
        key: String,
        value: Any?,
        completion: ((Error?) -> Void)? = nil
    ) {
        withCurrentSessionHandle(
            handler: { handle, session in
#if DEBUG
                logger.debug("Updating user property", [
                    "key": key,
                    "new value": String(describing: value),
                    "old value": String(describing: session.userProperties[key])
                ])
#endif

                let updatedSession = session.withUpdatedProperty(
                    key: key,
                    value: value
                )

                try self.writeSessionSync(
                    session: updatedSession,
                    with: handle
                )
            },
            completion: completion
        )
    }

    internal func writeUserPropertiesUpdate(
        newProperties: [String : AnyCodable],
        completion: ((Error?) -> Void)? = nil
    ) {
        withCurrentSessionHandle(
            handler: { handle, session in
                let updatedSession = session.withUpdatedProperties(
                    newProperties: newProperties
                )

                try self.writeSessionSync(
                    session: updatedSession,
                    with: handle
                )
            },
            completion: completion
        )
    }

    internal func writeEvent(
        event: ParraSessionEvent,
        completion: ((Error?) -> Void)? = nil
    ) {
        withCurrentSessionEventHandle(
            handler: { handle, session in
                // TODO: Need a much more compressed format.
                var data = try self.jsonEncoder.encode(event)
                data.append(Constant.newlineCharData)

                try handle.write(contentsOf: data)
                try handle.synchronize()
            },
            completion: completion
        )
    }

    // MARK: Retrieving Sessions

    internal func getAllSessions() async throws -> ParraSessionUploadGenerator {
        return try await withCheckedThrowingContinuation { continuation in
            getAllSessions { result in
                continuation.resume(with: result)
            }
        }
    }

    private func getAllSessions(
        completion: @escaping (Result<ParraSessionUploadGenerator, Error>) -> Void
    ) {
        withStorageQueue { sessionReader in
            do {
                let generator = try sessionReader.generateSessionUploadsSync()

                completion(.success(generator))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    /// Whether or not there are new events on the session since the last time a sync was completed.
    /// Will also return true if it isn't previously been called for the current session.
    internal func hasNewEvents() async -> Bool {
        return await withCheckedContinuation { continuation in
            hasNewEvents {
                continuation.resume(returning: $0)
            }
        }
    }

    private func hasNewEvents(completion: @escaping (Bool) -> Void) {
        withCurrentSessionEventHandle { handle, session in
            let currentOffset = try handle.offset()
            let lastSyncOffset = session.eventsHandleOffsetAtSync ?? 0

            // If there was a recorded offset at the time of a previous sync, there are new events if
            // the current offset has increased. If an offset wasn't set, a sync hasn't happened for this
            // session yet, and should occur.
            completion(currentOffset > lastSyncOffset)
        }
    }

    /// Whether or not there are sessions stored that have already finished. This implies that
    /// there is a session in progress that is not taken into consideration.
    internal func hasCompletedSessions() async -> Bool {
        return await withCheckedContinuation { continuation in
            hasCompletedSessions {
                continuation.resume(returning: $0)
            }
        }
    }

    private func hasCompletedSessions(completion: @escaping (Bool) -> Void) {
        withStorageQueue { sessionReader in
            do {
                let sessionDirectories = try self.sessionReader.getAllSessionDirectories()

                // The current session counts for 1. If there are more, they are the previous sessions.
                completion(sessionDirectories.count > 1)
            } catch let error {
                logger.error("Error checking for completed sessions", error)
                completion(false)
            }
        }
    }

    internal func recordSyncBegan() async {
        await withCheckedContinuation { continuation in
            recordSyncBegan {
                continuation.resume()
            }
        }
    }

    /// Store a marker to indicate that a sync just took place, so that events before that point
    /// can be purged.
    private func recordSyncBegan(completion: @escaping () -> Void) {
        withHandles { sessionHandle, eventsHandle, session in
            // Store the current offset of the file handle that writes events on the session object.
            // This will be used last to know if more events have been written since this point.
            let offset = try eventsHandle.offset()
            try self.writeSessionEventsOffsetUpdateSync(
                to: session,
                using: sessionHandle,
                offset: offset
            )

            completion()
        }
    }

    // MARK: Ending Sessions

    internal func endSession() async {
        // TODO: Need to be consistent with deinit. Both should mark session as ended, write the update, then close the session reader
//        sessionReader.closeCurrentSessionSync()
    }

    // MARK: Deleting Sessions

    /// Deletes any data associated with the sessions with the provided ids. This includes
    /// caches in memory and on disk. The current in progress session will not be deleted,
    /// even if its id is provided.
    internal func deleteSynchronizedData(for sessionIds: Set<String>) async {
        withHandles { sessionHandle, eventsHandle, currentSession in
            // Delete the directories for every session in sessionIds, except for the current session.
            let sessionDirectories = try self.sessionReader.getAllSessionDirectories()

            for sessionDirectory in sessionDirectories {
                let sessionId = sessionDirectory.deletingPathExtension().lastPathComponent
                logger.trace("Session iterator produced session", [
                    "sessionId": sessionId
                ])

                if sessionId != currentSession.sessionId && sessionIds.contains(sessionId) {
                    try self.sessionReader.deleteSessionSync(with: sessionId)
                }
            }

            logger.trace("Cleaning up previous events for current session")

            let currentEventsOffset = try eventsHandle.offset()
            let cachedEventsOffset = currentSession.eventsHandleOffsetAtSync ?? 0

            if currentEventsOffset > cachedEventsOffset {
                logger.trace("Current events offset is greater than cache. New events have happened", [
                    "current": currentEventsOffset,
                    "cached": cachedEventsOffset
                ])

                // Delete all events for the current session that were written by the time the sync began.

                // File handle doesn't provide a way to truncate from the beginning of the file.
                // We need to delete all the events that happened up until the point where a sync
                // was started:
                // 1. Seek to where the file handle was before the sync started.
                // 2. Read all new data from that point into memory.
                // 3. Reset the file back to a 0 offset.
                // 4. Write the cached data back to the file.

                try eventsHandle.seek(toOffset: cachedEventsOffset)
                if let data = try eventsHandle.readToEnd() {
                    logger.trace("Resetting events file with cached events")
                    try eventsHandle.truncate(atOffset: 0)

                    try eventsHandle.write(contentsOf: data)
                    logger.trace("Finished writing cached events to reset events file")
                } else {
                    logger.trace("New events couldn't be read")
                    // there are new events and the they can't be read
                    try eventsHandle.truncate(atOffset: 0)
                }
            } else {
                logger.trace("No new events occurred. Resetting events file")
                // No new events were written since the sync started. Resetting the events
                // file back to the beginning.
                try eventsHandle.truncate(atOffset: 0)
            }
            try eventsHandle.synchronize()

            // Reset the persisted events file handle offset on the session back to 0, since any
            // amount it was previously advanced by has been reset.
            try self.writeSessionEventsOffsetUpdateSync(
                to: currentSession,
                using: sessionHandle,
                offset: 0
            )
        }
    }

    // MARK: Helpers

    private func withCurrentSessionHandle(
        handler: @escaping (FileHandle, ParraSession) throws -> Void,
        completion: ((Error?) -> Void)? = nil
    ) {
        withHandle(
            for: .session,
            completion: completion,
            handler: handler
        )
    }

    private func withCurrentSessionEventHandle(
        handler: @escaping (FileHandle, ParraSession) throws -> Void,
        completion: ((Error?) -> Void)? = nil
    ) {
        withHandle(
            for: .events,
            completion: completion,
            handler: handler
        )
    }

    private func withHandles(
        completion: ((Error?) -> Void)? = nil,
        handler: @escaping (
            _ sessionHandle: FileHandle,
            _ eventsHandle: FileHandle,
            _ session: ParraSession
        ) throws -> Void
    ) {
        withStorageQueue { sessionReader in
            do {
                let context = try sessionReader.loadOrCreateSessionSync()

                let sessionHandle = try sessionReader.retreiveFileHandleForSessionSync(
                    with: .session,
                    from: context
                )

                let eventsHandle = try sessionReader.retreiveFileHandleForSessionSync(
                    with: .events,
                    from: context
                )

                try handler(sessionHandle, eventsHandle, context.session)

                completion?(nil)
            } catch let error {
                completion?(error)
            }
        }
    }

    private func withHandle(
        for type: FileHandleType,
        completion: ((Error?) -> Void)? = nil,
        handler: @escaping (FileHandle, ParraSession) throws -> Void
    ) {
        withStorageQueue { sessionReader in
            // TODO: Needs logic to see if the error is related to the file handle being closed, and auto attempt to reopen it.
            do {
                let context = try sessionReader.loadOrCreateSessionSync()
                let handle = try sessionReader.retreiveFileHandleForSessionSync(
                    with: type,
                    from: context
                )

                try handler(handle, context.session)

                completion?(nil)
            } catch let error {
                completion?(error)
            }
        }
    }

    private func withStorageQueue(
        block: @escaping (_ sessionReader: SessionReader) -> Void
    ) {
        storageQueue.async { [self] in
            block(sessionReader)
        }
    }

    private func writeSessionSync(
        session: ParraSession,
        with handle: FileHandle
    ) throws {
        // Always update the in memory cache of the current session before writing to disk.
        sessionReader.updateCachedCurrentSessionSync(
            to: session
        )

        let data = try jsonEncoder.encode(session)

        let offset = try handle.offset()
        if offset > data.count {
            // If the old file was longer, free the unneeded bytes
            try handle.truncate(atOffset: UInt64(data.count))
        }

        try handle.seek(toOffset: 0)
        try handle.write(contentsOf: data)
        try handle.synchronize()
    }

    private func writeSessionEventsOffsetUpdateSync(
        to session: ParraSession,
        using handle: FileHandle,
        offset: UInt64
    ) throws {
        logger.trace("Updating events file handle offset to: \(offset)")
        let updatedSession = session.withUpdatedEventsHandleOffset(
            offset: offset
        )

        try self.writeSessionSync(
            session: updatedSession,
            with: handle
        )
    }
}
