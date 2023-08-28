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

    internal func getAllSessions() async -> ParraSessionGenerator {
        return await withCheckedContinuation { continuation in
            getAllSessions {
                continuation.resume(returning: $0)
            }
        }
    }

    private func getAllSessions(completion: (ParraSessionGenerator) -> Void) {
        completion(ParraSessionGenerator(paths: []))
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

    internal func recordSyncComplete() async {

    }

    private func hasNewEvents(completion: (Bool) -> Void) {
        // TODO: This needs to track what the most recent session/event was when it is accessed, to know
        // if more events have happened or the session changed since that access.
        completion(false)
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
    internal func deleteCompletedSessions(with sessionIds: Set<String>) async {
        // TODO: Completed implies sessions other than the current session. Enforce this.
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
            let (handle, session) = try sessionReader.getFileHandleSync(
                with: type
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
