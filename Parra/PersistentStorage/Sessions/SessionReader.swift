//
//  SessionReader.swift
//  Parra
//
//  Created by Mick MacCallum on 8/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import Darwin

fileprivate let logger = Logger(bypassEventCreation: true, category: "SessionReader")

internal class SessionReader {
    /// The directory where sessions will be stored.
    internal let basePath: URL

    private let jsonDecoder: JSONDecoder

    /// This should never be used directly outside this class. From the outside, a session can and never
    /// should be nil. The idea is that session reads/writes will always happen on a serial queue, that
    /// will automatically create the session if it does not exist and await the completion of this
    /// operation. This is place where these checks will be made.
    private var currentSessionContext: SessionStorageContext?

    private var sessionHandle: FileHandle?
    private var eventsHandle: FileHandle?

    internal init(
        basePath: URL,
        jsonDecoder: JSONDecoder
    ) {
        self.basePath = basePath
        self.jsonDecoder = jsonDecoder
    }

    internal func getFileHandleSync(
        with type: FileHandleType
    ) throws -> (
        handle: FileHandle,
        session: ParraSession
    ) {
        let context = try loadOrCreateSessionSync()

        let handle: FileHandle?
        let path: URL
        switch type {
        case .session:
            handle = sessionHandle
            path = context.sessionPath
        case .events:
            handle = eventsHandle
            path = context.eventsPath
        }

        // TODO: Instead of requiring SessionStorage to always seek to the end of the events file before writing, could this auto perfom the seek whenever a new handle is created. Since an existing one will maintain its previous position.

        if let handle {
            // It is possible that we could still have a reference to the file handle, but its descriptor has
            // become invalid. If this happens, we need to close out the previous handle and create a new one.
            if isHandleValid(handle: handle) {
                return (handle, context.session)
            }

            // Close and fall back on the new handle creation flow.
            try handle.close()
        }

        let newHandle = try FileHandle(
            forUpdating: path
        )

        switch type {
        case .session:
            sessionHandle = newHandle
        case .events:
            try newHandle.seekToEnd()
            eventsHandle = newHandle
        }

        return (newHandle, context.session)
    }

    private func isHandleValid(handle: FileHandle) -> Bool {
        let descriptor = handle.fileDescriptor

        // Cheapest way to check if a descriptor is still valid, without attempting to read/write to it.
        return fcntl(descriptor, F_GETFL) != -1 || errno != EBADF
    }

    internal func closeCurrentSessionSync() throws {
        currentSessionContext = nil

        try sessionHandle?.close()
        try eventsHandle?.close()
    }

    @discardableResult
    private func loadOrCreateSessionSync() throws -> SessionStorageContext {
        // 1. If session context exists in memory, return it.
        // 2. Create the paths where the new session is to be stored, using time stamps.
        // 3. Check if the files already somehow exist. If they exist and are valid, use them.
        // 4. Create a new session at the determined paths, overriding anything that existed.
        // 5. Return the new session.

        if let currentSessionContext {
            return currentSessionContext
        }

        let fileManager = FileManager.default

        let nextSessionStart = Date.now
        let baseDirectory = ParraDataManager.Path.parraDirectory
            .safeAppendDirectory(Parra.persistentStorageFolder())
            .safeAppendDirectory("sessions")

        let (sessionPath, eventsPath) = sessionPaths(
            for: nextSessionStart,
            in: baseDirectory
        )

        var existingSession: ParraSession?
        do {
            if try fileManager.safeFileExists(at: sessionPath) {
                // The existence of this file implies all necessary intermediate directories have been created.

                let sessionData = try Data(contentsOf: sessionPath)
                existingSession = try jsonDecoder.decode(ParraSession.self, from: sessionData)

                // It is possible that the session existed, but events hadn't been written yet, so
                // this shouldn't fail if there is no file at the eventsPath.
                try fileManager.safeCreateFile(at: eventsPath)
            }
        } catch let error {
            existingSession = nil

            logger.error(error)
        }

        if let existingSession {
            let existingSessionContext = SessionStorageContext(
                session: existingSession,
                sessionPath: sessionPath,
                eventsPath: eventsPath
            )

            currentSessionContext = existingSessionContext

            return existingSessionContext
        }

        try fileManager.safeCreateDirectory(at: baseDirectory)
        try fileManager.safeCreateFile(at: sessionPath)
        try fileManager.safeCreateFile(at: eventsPath)

        let newSessionContext = SessionStorageContext(
            session: ParraSession(
                createdAt: nextSessionStart
            ),
            sessionPath: sessionPath,
            eventsPath: eventsPath
        )

        currentSessionContext = newSessionContext

        return newSessionContext
    }

    private func sessionPaths(
        for date: Date,
        in baseDirectory: URL
    ) -> (
        sessionPath: URL,
        eventsPath: URL
    ) {
        let timestamp = String(format: "%.0f", date.timeIntervalSince1970 * 1000000)
        let baseFileName = "session_\(timestamp)"

        // Just for conveinence while debugging to be able to open these files in an editor.
#if DEBUG
        let sessionFileName = "\(baseFileName).json"
        let eventsFileName = "\(baseFileName)_events.tsv"
#else
        let sessionFileName = "\(baseFileName)"
        let eventsFileName = "\(baseFileName)_events"
#endif

        return (
            sessionPath: baseDirectory.safeAppendPathComponent(sessionFileName),
            eventsPath: baseDirectory.safeAppendPathComponent(eventsFileName)
        )
    }
}
