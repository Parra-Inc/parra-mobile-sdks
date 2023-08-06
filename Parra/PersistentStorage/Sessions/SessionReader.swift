//
//  SessionReader.swift
//  Parra
//
//  Created by Mick MacCallum on 8/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal class SessionReader {
    /// The directory where sessions will be stored.
    internal let basePath: URL

    /// This should never be used directly outside this class. From the outside, a session can and never
    /// should be nil. The idea is that session reads/writes will always happen on a serial queue, that
    /// will automatically create the session if it does not exist and await the completion of this
    /// operation. This is place where these checks will be made.
    private var currentSession: ParraSession?

    internal init(basePath: URL) {
        self.basePath = basePath
    }

    /// Meant to trigger the loading or creation of a new session before events that would have done
    /// this occur.
    internal func initializeSync() {
        loadOrCreateSessionSync()
    }

    internal func getCurrentSessionContextSync() -> SessionStorageContext {

    }

    private func loadOrCreateSessionSync() -> ParraSession {

        // 1. Find

    }

    private func sessionPath(for session: ParraSession) -> URL {
        let baseUrl = ParraDataManager.Path.parraDirectory
            .safeAppendDirectory(Parra.persistentStorageFolder())
            .safeAppendDirectory("sessions")

        // Just for conveinence while debugging to be able to open these files in an editor.
#if DEBUG
        let fileName = "session_\(session.createdAt.timeIntervalSince1970).json"
#else
        let fileName = "session_\(session.createdAt.timeIntervalSince1970)"
#endif

        return baseUrl.safeAppendPathComponent(fileName)
    }

    private func eventsPath(for session: ParraSession) -> URL {
        let baseUrl = ParraDataManager.Path.parraDirectory
            .safeAppendDirectory(Parra.persistentStorageFolder())
            .safeAppendDirectory("sessions")

        return baseUrl.safeAppendPathComponent(
            "session_\(session.createdAt.timeIntervalSince1970)_events"
        )
    }
}
