//
//  SessionReaderTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/9/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

final class SessionReaderTests: MockedParraTestCase {
    // MARK: - Internal

    override func setUp() async throws {
        sessionReader = SessionReader(
            basePath: baseStorageDirectory,
            sessionJsonDecoder: .parraDecoder,
            eventJsonDecoder: .spaceOptimizedDecoder,
            fileManager: fileManager
        )
    }

    override func tearDown() async throws {
        try await super.tearDown()

        sessionReader = nil
    }

    func testCanRetreiveSessionFileHandleCreatesHandleIfUnset() async throws {
        let ctx = try createSessionContext()

        XCTAssertNil(sessionReader._sessionHandle)
        XCTAssertNil(sessionReader._eventsHandle)

        let fileHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .session,
            from: ctx
        )

        XCTAssertNotNil(sessionReader._sessionHandle)
        XCTAssertIdentical(fileHandle, sessionReader._sessionHandle)
        // Other handle should not have been created
        XCTAssertNil(sessionReader._eventsHandle)

        // Handle offset should be 0
        XCTAssertEqual(try fileHandle.offset(), 0)
    }

    func testCanRetreiveEventsFileHandleCreatesHandleIfUnset() async throws {
        let ctx = try createSessionContext()
        try fileManager.safeCreateFile(at: ctx.eventsPath)

        XCTAssertNil(sessionReader._eventsHandle)
        XCTAssertNil(sessionReader._sessionHandle)

        let fileHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .events,
            from: ctx
        )

        XCTAssertNotNil(sessionReader._eventsHandle)
        XCTAssertIdentical(fileHandle, sessionReader._eventsHandle)
        // Other handle should not have been created
        XCTAssertNil(sessionReader._sessionHandle)

        // Handle offset should be 0, since there are no events
        XCTAssertEqual(try fileHandle.offset(), 0)
    }

    func testCanRetreiveEventsFileHandleCreatesHandleIfUnsetWithExistingEvents(
    ) async throws {
        let ctx = try createSessionContext(includeEvents: true)

        XCTAssertNil(sessionReader._eventsHandle)
        XCTAssertNil(sessionReader._sessionHandle)

        let fileHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .events,
            from: ctx
        )

        XCTAssertNotNil(sessionReader._eventsHandle)
        XCTAssertIdentical(fileHandle, sessionReader._eventsHandle)
        // Other handle should not have been created
        XCTAssertNil(sessionReader._sessionHandle)

        let initialOffset = try fileHandle.offset()
        // If has events, offset after read should be greater than 0
        XCTAssertNotEqual(initialOffset, 0)
        try fileHandle.seekToEnd()
        // After seeking to end, the new offset didn't change, so initial offset
        // should have been at the end of the file.
        XCTAssertEqual(initialOffset, try fileHandle.offset())
    }

    func testCanRetreiveEventsFileHandleIfExists() async throws {
        let ctx = try createSessionContext(includeEvents: true)

        // Initial read to create the handle
        let initialHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .events,
            from: ctx
        )
        XCTAssertNotNil(sessionReader._eventsHandle)
        XCTAssertNotNil(initialHandle)

        let secondHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .events,
            from: ctx
        )
        XCTAssertNotNil(sessionReader._eventsHandle)
        XCTAssertNotNil(secondHandle)

        XCTAssertIdentical(initialHandle, secondHandle)
    }

    func testGetAllSessionDirectoriesGetsSessions() async throws {
        let contexts = try [
            createSessionContext(),
            createSessionContext(),
            createSessionContext()
        ]

        let allSessionDirectories = try sessionReader.getAllSessionDirectories()

        XCTAssertEqual(contexts.count, allSessionDirectories.count)
    }

    func _testCanRetreiveSessionFileHandleClosedIfInvalid() async throws {
        let ctx = try createSessionContext()

        // Initial read to create the handle
        let initialHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .session,
            from: ctx
        )

        // TODO: Would be nice to figure out how to test file handle becoming invalid.

        let secondHandle = try sessionReader.retreiveFileHandleForSessionSync(
            with: .session,
            from: ctx
        )
        XCTAssertNotNil(sessionReader._sessionHandle)
        XCTAssertNotNil(secondHandle)

        // Not identical. A new handle should have been created for the same file.
        XCTAssertNotIdentical(initialHandle, secondHandle)
    }

    func testGetAllSessionDirectoriesOmitsHiddenDirectories() async throws {
        try createSessionContext()
        try createSessionContext(hidden: true)
        try createSessionContext()

        let allSessionDirectories = try sessionReader.getAllSessionDirectories()

        XCTAssertEqual(allSessionDirectories.count, 2)
    }

    func testGetAllSessionDirectoriesHasPackageExtension() async throws {
        try createSessionContext()
        try createSessionContext()
        try createSessionContext(withoutPackageExt: true)
        try createSessionContext(withoutPackageExt: true)
        try createSessionContext()

        let allSessionDirectories = try sessionReader.getAllSessionDirectories()

        XCTAssertEqual(allSessionDirectories.count, 3)
    }

    func testCreatesSessionUploadGenerator() async throws {
        let contexts = try [
            createSessionContext(includeEvents: true),
            createSessionContext(includeEvents: true),
            createSessionContext(includeEvents: true)
        ]

        let generator = try sessionReader.generateSessionUploadsSync()

        var index = 0
        for await session in generator.makeAsyncIterator() {
            switch session {
            case .success(let sessionDirectory, _):
                let matchingContext = contexts.first { context in
                    context.sessionPath
                        .deletingLastPathComponent() == sessionDirectory
                }

                XCTAssertNotNil(matchingContext)
            case .error(_, let error):
                throw error
            }

            index += 1
        }
    }

    func testClosingCurrentSessionClosesHandles() async throws {
        let ctx = try createSessionContext(includeEvents: true)

        XCTAssertNil(sessionReader._sessionHandle)
        XCTAssertNil(sessionReader._eventsHandle)

        let _ = try sessionReader.retreiveFileHandleForSessionSync(
            with: .session,
            from: ctx
        )
        let _ = try sessionReader.retreiveFileHandleForSessionSync(
            with: .events,
            from: ctx
        )

        XCTAssertNotNil(sessionReader._sessionHandle)
        XCTAssertNotNil(sessionReader._eventsHandle)

        try sessionReader.closeCurrentSessionSync()

        XCTAssertNil(sessionReader._sessionHandle)
        XCTAssertNil(sessionReader._eventsHandle)
    }

    func testClosingCurrentSessionRemovesCachedContext() async throws {
        let ctx = try sessionReader.loadOrCreateSessionSync()

        let _ = try sessionReader.retreiveFileHandleForSessionSync(
            with: .session,
            from: ctx
        )
        let _ = try sessionReader.retreiveFileHandleForSessionSync(
            with: .events,
            from: ctx
        )

        XCTAssertNotNil(sessionReader._currentSessionContext)

        try sessionReader.closeCurrentSessionSync()

        XCTAssertNil(sessionReader._currentSessionContext)
    }

    func testLoadOrCreateCreatesIfNoSessionExists() async throws {
        XCTAssertNil(sessionReader._currentSessionContext)

        let _ = try sessionReader.loadOrCreateSessionSync()

        XCTAssertNotNil(sessionReader._currentSessionContext)
    }

    func testLoadOrCreateReturnsCachedSession() async throws {
        let ctx1 = try sessionReader.loadOrCreateSessionSync()

        let ctx2 = try sessionReader.loadOrCreateSessionSync()

        XCTAssertEqual(ctx1, ctx2)
    }

    func testLoadOrCreateLoadsFromDiskIfExistsAndValid() async throws {
        // Create a fake context, which is stored.
        let fakeSessionCtx = try createSessionContext()

        XCTAssertNil(sessionReader._currentSessionContext)

        let _ = try sessionReader.loadOrCreateSessionSync(
            nextSessionId: fakeSessionCtx.session.sessionId
        )

        XCTAssertNotNil(sessionReader._currentSessionContext)
    }

    func testLoadOrCreateCreatesIfDiskCacheIsInvalid() async throws {
        // Create a fake context, which is stored.
        let fakeSessionCtx = try createSessionContext()

        XCTAssertNil(sessionReader._currentSessionContext)

        let corruptJsonData = "i am not real json".data(using: .utf8)!
        try corruptJsonData.write(
            to: fakeSessionCtx.sessionPath,
            options: .atomic
        )

        let newCtx = try sessionReader.loadOrCreateSessionSync(
            nextSessionId: fakeSessionCtx.session.sessionId
        )

        XCTAssertNotNil(sessionReader._currentSessionContext)
        XCTAssertEqual(sessionReader._currentSessionContext, newCtx)
    }

    func testUpdateCachedSession() async throws {
        let _ = try sessionReader.loadOrCreateSessionSync()

        let newSession = ParraSession(
            sessionId: UUID().uuidString,
            createdAt: Date(),
            sdkVersion: ParraInternal.libraryVersion()
        )

        XCTAssertNotNil(sessionReader._currentSessionContext)
        XCTAssertNotEqual(
            newSession,
            sessionReader._currentSessionContext?.session
        )

        sessionReader.updateCachedCurrentSessionSync(
            to: newSession
        )

        XCTAssertEqual(
            newSession,
            sessionReader._currentSessionContext?.session
        )
    }

    func testDeletingSessionRemovesSessionDirectory() async throws {
        let ctx = try sessionReader.loadOrCreateSessionSync()

        try sessionReader.deleteSessionSync(
            with: ctx.session.sessionId
        )

        let exists = try fileManager.safeDirectoryExists(
            at: ctx.eventsPath.deletingLastPathComponent()
        )

        XCTAssertFalse(exists)
    }

    func testMarkingErroredSession() async throws {
        let ctx = try sessionReader.loadOrCreateSessionSync()
        let sessionDir = ctx.sessionPath.deletingLastPathComponent()

        XCTAssertFalse(sessionDir.lastPathComponent.hasPrefix("_"))

        try sessionReader.markSessionErrored(
            with: ctx.session.sessionId
        )

        XCTAssertFalse(try fileManager.safeDirectoryExists(at: sessionDir))

        let markedDir = "_\(sessionDir.lastPathComponent)"
        let newSessionDir = sessionDir.deletingLastPathComponent()
            .appendFilename(markedDir)

        XCTAssertTrue(try fileManager.safeDirectoryExists(at: newSessionDir))
    }

    // MARK: - Private

    private let fileManager = FileManager.default
    private var sessionReader: SessionReader!

    @discardableResult
    private func createSessionContext(
        id: String = UUID().uuidString,
        hidden: Bool = false,
        withoutPackageExt: Bool = false,
        includeEvents: Bool = false
    ) throws -> SessionStorageContext {
        var sessionDirectory = sessionReader.sessionDirectory(
            for: id,
            in: sessionReader.basePath
        )

        if hidden {
            let last = ".\(sessionDirectory.lastPathComponent)"

            sessionDirectory = sessionDirectory
                .deletingLastPathComponent()
                .appendFilename(last)
        }

        if withoutPackageExt {
            sessionDirectory = sessionDirectory.deletingPathExtension()
        }

        let (sessionPath, eventsPath) = SessionReader.sessionPaths(
            in: sessionDirectory
        )

        try fileManager.safeCreateDirectory(at: sessionDirectory)

        let context = SessionStorageContext(
            session: ParraSession(
                sessionId: id,
                createdAt: Date(),
                sdkVersion: ParraInternal.libraryVersion()
            ),
            sessionPath: sessionPath,
            eventsPath: eventsPath
        )

        try fileManager.safeCreateFile(at: sessionPath)
        try createSession(
            at: sessionPath,
            sessionId: id
        )

        if includeEvents {
            try fileManager.safeCreateFile(at: eventsPath)
            try createSessionEvents(at: eventsPath)
        }

        return context
    }

    private func createSession(
        at path: URL,
        sessionId: String
    ) throws {
        let session = ParraSession(
            sessionId: sessionId,
            createdAt: Date(),
            sdkVersion: ParraInternal.libraryVersion()
        )

        let handle = try FileHandle(forWritingTo: path)
        defer {
            try! handle.close()
        }

        let data = try JSONEncoder.parraEncoder.encode(session)

        try handle.write(contentsOf: data)
        try handle.synchronize()
    }

    private func createSessionEvents(
        at path: URL
    ) throws {
        let events = [
            ParraSessionEvent(
                createdAt: Date().addingTimeInterval(-10_000.0),
                name: "first event",
                metadata: [:]
            ),
            ParraSessionEvent(
                createdAt: Date().addingTimeInterval(-8_000.0),
                name: "second event",
                metadata: [:]
            ),
            ParraSessionEvent(
                createdAt: Date().addingTimeInterval(-4_000.0),
                name: "third event",
                metadata: [:]
            )
        ]

        // Keep after createSessionSync, since it will create intermediate directories.
        let handle = try FileHandle(forWritingTo: path)
        defer {
            try! handle.close()
        }

        for event in events {
            var data = try JSONEncoder.spaceOptimizedEncoder.encode(event)
            data.append("\n".data(using: .utf8)!)

            try handle.write(contentsOf: data)
            try handle.synchronize()
        }
    }
}
