//
//  SessionStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 11/20/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

// TODO: Need to address issue where the current system of storing the events file handle offset
// always means there are new events to sync, because new events that should be synced are created
// by completing a sync.

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

    /// Whether or not, since the last time a sync occurred, session storage received
    /// a new event with a context object that indicated that it was a high priority
    /// event.
    private var hasReceivedImportantEvent = false

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
        logger.debug("initializing at path: \(sessionReader.basePath.lastComponents())")

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
            } completion: { (result: Result<Void, Error>) in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    logger.error("Error initializing session", error)
                    continuation.resume()
                }
            }
        }
    }

    internal func getCurrentSession() async throws -> ParraSession {
        return try await withCheckedThrowingContinuation { continuation in
            getCurrentSession { result in
                continuation.resume(with: result)
            }
        }
    }

    private func getCurrentSession(
        completion: @escaping (Result<ParraSession, Error>) -> Void
    ) {
        withCurrentSessionHandle(
            handler: { _, session in
                return session
            },
            completion: completion
        )
    }

    // MARK: Updating Sessions

    internal func writeUserPropertyUpdate(
        key: String,
        value: Any?
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
            completion: nil
        )
    }

//    internal func writeUserPropertiesUpdate(
//        newProperties: [String : AnyCodable],
//        completion: ((Error?) -> Void)? = nil
//    ) {
//        withCurrentSessionHandle(
//            handler: { handle, session in
//                let updatedSession = session.withUpdatedProperties(
//                    newProperties: newProperties
//                )
//
//                try self.writeSessionSync(
//                    session: updatedSession,
//                    with: handle
//                )
//            },
//            completion: completion
//        )
//    }

    private func storeEventContextUpdateSync(
        context: ParraSessionEventContext
    ) {
        if hasReceivedImportantEvent {
            // It doesn't matter if multiple important events are recievd. The first one
            // is enough to set the flag.
            return
        }

        if context.isClientGenerated {
            hasReceivedImportantEvent = true

            return
        }

        if [.high, .critical].contains(context.syncPriority) {
            hasReceivedImportantEvent = true
        }
    }

    internal func writeEvent(
        event: ParraSessionEvent,
        context: ParraSessionEventContext
    ) {
        withHandles { sessionHandle, eventsHandle, session in
            self.storeEventContextUpdateSync(context: context)

            var data = try self.jsonEncoder.encode(event)
            data.append(Constant.newlineCharData)

            try eventsHandle.write(contentsOf: data)
            try eventsHandle.synchronize()
        } completion: { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                logger.error("Error writing event to session", error)
            }
        }
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
        do {
            return try await withCheckedThrowingContinuation { continuation in
                hasNewEvents { result in
                    continuation.resume(with: result)
                }
            }
        } catch let error {
            logger.error("Error checking if session has new events", error)

            return false
        }
    }

    private func hasNewEvents(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        withCurrentSessionEventHandle(
            handler: { [self] _, _ in
                return hasReceivedImportantEvent
            },
            completion: completion
        )
    }

    internal func hasSessionUpdates(since date: Date?) async -> Bool {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                hasSessionUpdates(since: date) { result in
                    continuation.resume(with: result)
                }
            }
        } catch let error {
            logger.error("Error checking if session has updates", error)

            return false
        }
    }

    private func hasSessionUpdates(
        since date: Date?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        withCurrentSessionHandle(
            handler: { _, session in
                return session.hasBeenUpdated(since: date)
            },
            completion: completion
        )
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

    private func hasCompletedSessions(
        completion: @escaping (Bool) -> Void
    ) {
        withStorageQueue { sessionReader in
            do {
                let sessionDirectories = try self.sessionReader.getAllSessionDirectories()
                let ext = ParraSession.Constant.packageExtension
                let nonErroredSessions = sessionDirectories.filter { directory in
                    // Anything that is somehow in the sessions directory without the
                    // appropriate path extension should be counted towards completed sessions.
                    guard directory.pathExtension == ext else {
                        return false
                    }

                    let sessionId = directory.deletingPathExtension().lastPathComponent

                    // Sessions that have errored are marked with an underscore prefix to
                    // their names. These sessions shouldn't count when checking if there
                    // are new sessions to sync, but will be picked up when a new session
                    // causes a sync to be necessary.
                    return !sessionId.hasPrefix("_")
                }

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
            recordSyncBegan { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    logger.error("Error recording sync marker on session", error)

                    continuation.resume()
                }
            }
        }
    }

    /// Store a marker to indicate that a sync just took place, so that events before that point
    /// can be purged.
    private func recordSyncBegan(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        withHandles(
            handler: { [self] sessionHandle, eventsHandle, session in
                // Store the current offset of the file handle that writes events on the session object.
                // This will be used last to know if more events have been written since this point.
                let offset = try eventsHandle.offset()

                hasReceivedImportantEvent = false

                try writeSessionEventsOffsetUpdateSync(
                    to: session,
                    using: sessionHandle,
                    offset: offset
                )
            },
            completion: completion
        )
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
    internal func deleteSessions(
        for sessionIds: Set<String>,
        erroredSessions erroredSessionIds: Set<String>
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            deleteSessions(
                for: sessionIds,
                erroredSessions: erroredSessionIds
            ) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func deleteSessions(
        for sessionIds: Set<String>,
        erroredSessions erroredSessionIds: Set<String>,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        withHandles(
            handler: { sessionHandle, eventsHandle, currentSession in
                // Delete the directories for every session in sessionIds, except for the current session.
                let sessionDirectories = try self.sessionReader.getAllSessionDirectories()

                for sessionDirectory in sessionDirectories {
                    let sessionId = sessionDirectory.deletingPathExtension().lastPathComponent
                    logger.trace("Session iterator produced session", [
                        "sessionId": sessionId
                    ])

                    if sessionId == currentSession.sessionId {
                        continue
                    }

                    if sessionIds.contains(sessionId) {
                        try self.sessionReader.deleteSessionSync(with: sessionId)
                    }

                    if erroredSessionIds.contains(sessionId) {
                        try self.sessionReader.markSessionErrored(with: sessionId)
                    }
                }

                logger.trace("Cleaning up previous events for current session")

                let currentEventsOffset = try eventsHandle.offset()
                let cachedEventsOffset = currentSession.eventsHandleOffsetAtSync ?? 0

                if currentEventsOffset > cachedEventsOffset {
                    logger.trace(
                        "Current events offset is greater than cache. New events have happened",
                        [
                            "current": currentEventsOffset,
                            "cached": cachedEventsOffset
                        ]
                    )

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

                    try eventsHandle.synchronize()

                    let newOffset = try eventsHandle.offset()

                    // Store the new position of the file handle as the last synced offset
                    // on the session. There are two situations that this handles:
                    // 1. There were no events written since the start of the sync. In this
                    //    case, the new offset will be reset to 0. This is the same situation
                    //    as the else block below.
                    // 2. There were events written between when the sync started and ended.
                    //    It is expected that this is generally true, since networking events
                    //    related to syncing will occur. When this happens, we advance the
                    //    value of the last synchronized offset to be that of the handle,
                    //    after storing these events that happened during sync. This has the
                    //    drawback of meaning that these events won't be synchronized until
                    //    some other events are created later, but has the benefit of helping
                    //    break an infinite sync loop.

                    try self.writeSessionEventsOffsetUpdateSync(
                        to: currentSession,
                        using: sessionHandle,
                        offset: newOffset
                    )
                } else {
                    logger.trace("No new events occurred. Resetting events file")

                    // No new events were written since the sync started. Resetting the
                    // events file back to the beginning.
                    try eventsHandle.truncate(atOffset: 0)
                    try eventsHandle.synchronize()

                    try self.writeSessionEventsOffsetUpdateSync(
                        to: currentSession,
                        using: sessionHandle,
                        offset: 0
                    )
                }
            },
            completion: completion
        )
    }

    // MARK: Helpers

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

// MARK: withHandle helpers

extension SessionStorage {
    private func withCurrentSessionHandle<T>(
        handler: @escaping (FileHandle, ParraSession) throws -> T,
        completion: ((Result<T, Error>) -> Void)? = nil
    ) {
        withHandle(
            for: .session,
            completion: completion,
            handler: handler
        )
    }

    private func withCurrentSessionEventHandle<T>(
        handler: @escaping (FileHandle, ParraSession) throws -> T,
        completion: ((Result<T, Error>) -> Void)? = nil
    ) {
        withHandle(
            for: .events,
            completion: completion,
            handler: handler
        )
    }

    private func withHandles<T>(
        handler: @escaping (
            _ sessionHandle: FileHandle,
            _ eventsHandle: FileHandle,
            _ session: ParraSession
        ) throws -> T,
        completion: ((Result<T, Error>) -> Void)? = nil
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

                completion?(
                    .success(try handler(sessionHandle, eventsHandle, context.session))
                )
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    private func withHandle<T>(
        for type: FileHandleType,
        completion: ((Result<T, Error>) -> Void)? = nil,
        handler: @escaping (FileHandle, ParraSession) throws -> T
    ) {
        withStorageQueue { sessionReader in
            // TODO: Needs logic to see if the error is related to the file handle being closed, and auto attempt to reopen it.
            do {
                let context = try sessionReader.loadOrCreateSessionSync()
                let handle = try sessionReader.retreiveFileHandleForSessionSync(
                    with: type,
                    from: context
                )

                completion?(
                    .success(try handler(handle, context.session))
                )
            } catch let error {
                completion?(.failure(error))
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
}
