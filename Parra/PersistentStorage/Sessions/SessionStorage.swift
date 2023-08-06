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

    private var sessionHandle: FileHandle?
    private var eventHandle: FileHandle?

    private let sessionReader: SessionReader

    internal init(sessionReader: SessionReader) {
        self.sessionReader = sessionReader

        logger.debug("initializing at path: \(sessionReader.basePath.safeNonEncodedPath())")
    }

    deinit {
        logger.trace("deinit")

        do {
            try sessionHandle?.close()
            try eventHandle?.close()
        } catch let error {
            logger.error("Error closing file handles", error)
        }
    }

    internal func initializeSessions() async {
        await withCheckedContinuation { continuation in
            storageQueue.async {
                self.sessionReader.initializeSync()

                continuation.resume()
            }
        }
    }

    // MARK: Updating Sessions

    internal func writeUserPropertyUpdate(
        completion: ((Error?) -> Void)? = nil
    ) {

        withCurrentSessionHandle(
            handler: { handle, session in
                let data = try JSONEncoder.parraEncoder.encode(session)

                let offset = try handle.offset()
                if offset > data.count {
                    // If the old file was longer, free the unneeded bytes
                    try handle.truncate(atOffset: UInt64(data.count))
                }

                try handle.seek(toOffset: 0)
                try handle.write(contentsOf: data)
                try handle.synchronize()
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
                var data = try JSONEncoder.parraEncoder.encode(event)
                data.append(Constant.newlineCharData)

                try handle.seekToEnd()
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

    }

    /// Whether or not there are new events on the session since the last time ``recordSync`` was called.
    /// Will also return true if it isn't previously been called for the current session.
    internal func hasNewEvents() async -> Bool {
        return await withCheckedContinuation { continuation in
            hasNewEvents {
                continuation.resume(returning: $0)
            }
        }
    }

    internal func recordSync() async {

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
            let context = sessionReader.getCurrentSessionContextSync()

            withHandle(
                for: context.session,
                at: context.path,
                handle: &sessionHandle,
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
            let context = sessionReader.getCurrentSessionContextSync()

            withHandle(
                for: context.session,
                at: context.eventsPath,
                handle: &eventHandle,
                completion: completion,
                handler: handler
            )
        }
    }

    private func withHandle(
        for session: ParraSession,
        at path: URL,
        handle: inout FileHandle?,
        completion: ((Error?) -> Void)? = nil,
        handler: @escaping (FileHandle, ParraSession) throws -> Void
    ) {
        do {
            if let handle {
                try handler(handle, session)
            } else {
                // TODO: This might actually be a critical enough error to justify keeping the bang.
                let newHandle = try FileHandle(forUpdating: path)
                handle = newHandle
                try handler(newHandle, session)
            }

            completion?(nil)
        } catch let error {
            completion?(error)
        }
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
