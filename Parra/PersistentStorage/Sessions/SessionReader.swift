//
//  SessionReader.swift
//  Parra
//
//  Created by Mick MacCallum on 8/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Darwin
import Foundation

private let logger = Logger(
    bypassEventCreation: true,
    category: "SessionReader"
)

class SessionReader {
    // MARK: Lifecycle

    init(
        basePath: URL,
        sessionJsonDecoder: JSONDecoder,
        eventJsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) {
        self.basePath = basePath
        self.sessionJsonDecoder = sessionJsonDecoder
        self.eventJsonDecoder = eventJsonDecoder
        self.fileManager = fileManager
    }

    deinit {
        _currentSessionContext = nil

        do {
            try _sessionHandle?.close()
            try _eventsHandle?.close()
        } catch {
            logger.error(
                "Error closing session/events file handles while closing session reader",
                error
            )
        }

        _sessionHandle = nil
        _eventsHandle = nil
    }

    // MARK: Internal

    /// The directory where sessions will be stored.
    let basePath: URL

    /// This should never be used directly outside this class. From the outside, a session can and never
    /// should be nil. The idea is that session reads/writes will always happen on a serial queue, that
    /// will automatically create the session if it does not exist and await the completion of this
    /// operation. This is place where these checks will be made.
    private(set) var _currentSessionContext: SessionStorageContext?

    private(set) var _sessionHandle: FileHandle?
    private(set) var _eventsHandle: FileHandle?

    static func sessionPaths(
        in sessionDirectory: URL
    ) -> (
        sessionPath: URL,
        eventsPath: URL
    ) {
        // Just for conveinence while debugging to be able to open these files in an editor.
        #if DEBUG
        let sessionFileName = "session.json"
        let eventsFileName = "events.csv"
        #else
        let sessionFileName = "session"
        let eventsFileName = "events"
        #endif

        return (
            sessionPath: sessionDirectory.appendFilename(sessionFileName),
            eventsPath: sessionDirectory.appendFilename(eventsFileName)
        )
    }

    func retreiveFileHandleForSessionSync(
        with type: FileHandleType,
        from context: SessionStorageContext
    ) throws -> FileHandle {
        let handle: FileHandle?
        let path: URL
        switch type {
        case .session:
            handle = _sessionHandle
            path = context.sessionPath
        case .events:
            handle = _eventsHandle
            path = context.eventsPath
        }

        if let handle {
            // It is possible that we could still have a reference to the file handle, but its descriptor has
            // become invalid. If this happens, we need to close out the previous handle and create a new one.
            if isHandleValid(handle: handle) {
                return handle
            }

            // Close and fall back on the new handle creation flow.
            try handle.close()
        }

        let newHandle = try FileHandle(
            forUpdating: path
        )

        switch type {
        case .session:
            _sessionHandle = newHandle
        case .events:
            // Unlike the handle that writes to sessions, the events handle will always be used to append to
            // the end of the file. So if we're creating a new one, we can seek to the end of the file now
            // to prevent this from being necessary each time it is accessed.
            try newHandle.seekToEnd()
            _eventsHandle = newHandle
        }

        return newHandle
    }

    func getAllSessionDirectories() throws -> [URL] {
        logger.trace("Getting all session directories")

        let directories = try fileManager.contentsOfDirectory(
            at: basePath,
            includingPropertiesForKeys: [],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        )

        return directories.filter { directory in
            return directory.hasDirectoryPath
                && directory.pathExtension == ParraSession.Constant
                .packageExtension
        }
    }

    func generateSessionUploadsSync() throws -> ParraSessionUploadGenerator {
        logger.trace("Creating session upload generator")

        return try ParraSessionUploadGenerator(
            forSessionsAt: basePath,
            sessionJsonDecoder: sessionJsonDecoder,
            eventJsonDecoder: eventJsonDecoder,
            fileManager: fileManager
        )
    }

    func closeCurrentSessionSync() throws {
        _currentSessionContext = nil

        try _sessionHandle?.close()
        try _eventsHandle?.close()

        _sessionHandle = nil
        _eventsHandle = nil
    }

    @discardableResult
    func loadOrCreateSessionSync(
        nextSessionId: String = UUID().uuidString
    ) throws -> SessionStorageContext {
        // 1. If session context exists in memory, return it.
        // 2. Create the paths where the new session is to be stored, using time stamps.
        // 3. Check if the files already somehow exist. If they exist and are valid, use them.
        // 4. Create a new session at the determined paths, overriding anything that existed.
        // 5. Return the new session.

        if let _currentSessionContext {
            return _currentSessionContext
        }

        let nextSessionStart = Date.now
        let sessionDir = sessionDirectory(
            for: nextSessionId,
            in: basePath
        )

        let (sessionPath, eventsPath) = SessionReader.sessionPaths(
            in: sessionDir
        )

        var existingSession: ParraSession?
        do {
            if try fileManager.safeFileExists(at: sessionPath) {
                // The existence of this file implies all necessary intermediate directories have been created.

                let sessionData = try Data(contentsOf: sessionPath)
                existingSession = try sessionJsonDecoder.decode(
                    ParraSession.self,
                    from: sessionData
                )

                // It is possible that the session existed, but events hadn't been written yet, so
                // this shouldn't fail if there is no file at the eventsPath.
                try fileManager.safeCreateFile(at: eventsPath)
            }
        } catch {
            existingSession = nil

            logger.error(error)
        }

        if let existingSession {
            let existingSessionContext = SessionStorageContext(
                session: existingSession,
                sessionPath: sessionPath,
                eventsPath: eventsPath
            )

            _currentSessionContext = existingSessionContext

            return existingSessionContext
        }

        try fileManager.safeCreateDirectory(
            at: sessionDir
        )
        try fileManager.safeCreateFile(
            at: sessionPath,
            overrideExisting: true
        )
        try fileManager.safeCreateFile(
            at: eventsPath,
            overrideExisting: true
        )

        let nextSessionContext = SessionStorageContext(
            session: ParraSession(
                sessionId: nextSessionId,
                createdAt: nextSessionStart,
                sdkVersion: Parra.libraryVersion()
            ),
            sessionPath: sessionPath,
            eventsPath: eventsPath
        )

        _currentSessionContext = nextSessionContext

        return nextSessionContext
    }

    func updateCachedCurrentSessionSync(
        to newSession: ParraSession
    ) {
        _currentSessionContext?.updateSession(
            to: newSession
        )
    }

    func deleteSessionSync(with id: String) throws {
        let sessionDir = sessionDirectory(
            for: id,
            in: basePath
        )

        try fileManager.removeItem(at: sessionDir)
    }

    func markSessionErrored(with id: String) throws {
        let currentSessionDirectory = sessionDirectory(
            for: id,
            in: basePath
        )

        let erroredSessionDirectory = sessionDirectory(
            for: "_\(id)",
            in: basePath
        )

        try fileManager.moveItem(
            at: currentSessionDirectory,
            to: erroredSessionDirectory
        )
    }

    func sessionDirectory(
        for id: String,
        in baseDirectory: URL
    ) -> URL {
        // TODO: Use FileWrapper to make it so we can actually open these as bundles.
        // Note: Using a file wrapper may require changing the file enumerator to filter by isPackage
        // instead of isDirectory.
        return baseDirectory
            .appendDirectory("\(id).\(ParraSession.Constant.packageExtension)")
    }

    // MARK: Private

    private let sessionJsonDecoder: JSONDecoder
    private let eventJsonDecoder: JSONDecoder
    private let fileManager: FileManager

    // MARK: Private methods

    private func isHandleValid(handle: FileHandle) -> Bool {
        let descriptor = handle.fileDescriptor

        // Cheapest way to check if a descriptor is still valid, without attempting to read/write to it.
        return fcntl(descriptor, F_GETFL) != -1 || errno != EBADF
    }
}
