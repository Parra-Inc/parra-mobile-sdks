//
//  SessionStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 11/20/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

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

    internal func getAllSessions() async throws -> ParraSessionGenerator {
        return try await withCheckedThrowingContinuation { continuation in
            getAllSessions { result in
                continuation.resume(with: result)
            }
        }
    }

    private func getAllSessions(
        completion: @escaping (Result<ParraSessionGenerator, Error>) -> Void
    ) {
        storageQueue.async {
            do {
                let generator = try self.sessionReader.generatePreviousSessionsSync()

                completion(.success(generator))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    /// Whether or not there are new events on the session since the last time ``recordSyncComplete`` was called.
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

    /// Store a marker to indicate that a sync just took place, so that events before that point
    /// can be purged.
    private func recordSyncComplete(completion: @escaping () -> Void) {
        withCurrentSessionHandle { [self] sessionHandle, session in
            withHandleSync(for: .events) { eventsHandle, _ in
                // Store the current offset of the file handle that writes events on the session object.
                // This will be used last to know if more events have been written since this point.
                let offset = try eventsHandle.offset()
                let updatedSession = session.withUpdatedEventsHandleOffset(
                    offset: offset
                )

                try self.writeSessionSync(
                    session: updatedSession,
                    with: sessionHandle
                )
            }
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

    private func hasCompletedSessions(completion: (Bool) -> Void) {
        // TODO
        completion(false)
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
        // TODO: Should fully delete all session artifacts for all sessions other than the current one.
        // TODO: For the current session, should delete all events that have been sync'd and update the persisted offset. Using the following:

//        // Reset and update the cache for the current session so the most up to take data is uploaded.
//        await sessionStorage.recordSyncComplete()

    }

    // MARK: Helpers

    private func withCurrentSessionHandle(
        handler: @escaping (FileHandle, ParraSession) throws -> Void,
        completion: ((Error?) -> Void)? = nil
    ) {
        storageQueue.async { [self] in
            withHandleSync(
                for: .session,
                completion: completion,
                handler: handler
            )
        }
    }

    private func withCurrentSessionEventHandle(
        handler: @escaping (FileHandle, ParraSession) throws -> Void,
        completion: ((Error?) -> Void)? = nil
    ) {
        storageQueue.async { [self] in
            withHandleSync(
                for: .events,
                completion: completion,
                handler: handler
            )
        }
    }

    private func withHandleSync(
        for type: FileHandleType,
        completion: ((Error?) -> Void)? = nil,
        handler: @escaping (FileHandle, ParraSession) throws -> Void
    ) {
        // TODO: Needs logic to see if the error is related to the file handle being closed, and auto attempt to reopen it.
        do {
            let context = try sessionReader.loadOrCreateSessionSync()
            let (handle, session) = try sessionReader.retreiveCurrentSessionSync(
                with: type,
                from: context
            )

            try handler(handle, session)

            completion?(nil)
        } catch let error {
            completion?(error)
        }
    }

    private func writeSessionSync(
        session: ParraSession,
        with handle: FileHandle
    ) throws {
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
}

//internal actor SessionStorage: ItemStorage {
//    typealias DataType = ParraSession
//
//    let storageModule: ParraStorageModule<ParraSession>
//
//    init(storageModule: ParraStorageModule<ParraSession>) {
//        self.storageModule = storageModule
//    }
//
//    func update(session: ParraSession) async throws {
//        try await storageModule.write(
//            name: session.sessionId,
//            value: session
//        )
//    }
//
//    func deleteSessions(with sessionIds: Set<String>) async {
//        for sessionId in sessionIds {
//            await storageModule.delete(name: sessionId)
//        }
//    }
//
//    func allTrackedSessions() async -> [ParraSession] {
//        let sessions = await storageModule.currentData()
//
//        return sessions.sorted { (first, second) in
//            let firstKey = Float(first.key) ?? 0
//            let secondKey = Float(second.key) ?? 0
//
//            return firstKey < secondKey
//        }.map { (key: String, value: ParraSession) in
//            return value
//        }
//    }
//
//    func numberOfTrackedSessions() async -> Int {
//        let sessions = await storageModule.currentData()
//
//        return sessions.count
//    }
//}
