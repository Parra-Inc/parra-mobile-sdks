//
//  ExceptionHandler.swift
//  Sample
//
//  Created by Mick MacCallum on 7/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Darwin
import Dispatch
import Foundation
import ObjectiveC

// Global function to handle uncaught exceptions
func parraExceptionHandler(_ exception: NSException) {
    ExceptionHandler.handleUncaughtException(exception)
}

enum ExceptionHandler {
    // MARK: - Internal

    static let signals: [Int32] = [
        SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE, SIGTRAP, SIGTERM
    ]

    static func setCurrentSessionId(_ sessionId: String) {
        currentSessionId = sessionId
    }

    static func addSignalListeners() {
        for signal in signals {
            Darwin.signal(signal, ExceptionHandler.handleSignal)
        }
    }

    /// CAN NOT BE CALLED MORE THAN ONCE.
    static func addExceptionHandlers() {
        existingHandler = NSGetUncaughtExceptionHandler()

        NSSetUncaughtExceptionHandler(parraExceptionHandler)
    }

    static func handleUncaughtException(
        _ exception: NSException
    ) {
        let demangledFrames = CallStackParser.parse(
            frames: exception.callStackSymbols
        )

        let frames = ParraLoggerStackSymbols.demangled(
            demangledFrames
        ).frameStrings

        let crash = CrashInfo(
            sessionId: currentSessionId,
            type: .exception,
            name: exception.name.rawValue,
            reason: exception.reason ?? "",
            callStack: frames
        )

        persistCrash(crash)

        // Forward to previous handler if it exists
        existingHandler?(exception)
    }

    // MARK: - Private

    // Reference the existing handler, so that we don't override crash reporting
    // libraries that the developer may be using. This will be invoked after our own
    // crash handler.
    private static var existingHandler: NSUncaughtExceptionHandler?
    private static var currentSessionId: String?

    private static let handleSignal: @convention(c) (Int32) -> Void = {
        signal in

        let frames = CallStackParser.backtrace().frameStrings
        let signalName = name(of: signal)
        let reason = "Signal \(signalName)(\(signal)) was raised.\n"

        let crash = CrashInfo(
            sessionId: currentSessionId,
            type: .signal,
            name: signalName,
            reason: reason,
            callStack: frames
        )

        persistCrash(crash)

        exit(signal)
    }

    private static func name(
        of signal: Int32
    ) -> String {
        guard let name = strsignal(signal) else {
            return "UNKNOWN"
        }

        return String(cString: name)
    }

    private static func persistCrash(
        _ crashInfo: ExceptionHandler.CrashInfo
    ) {
        let timestamp = Date.now.timeIntervalSince1970
        let crashReportPath = DataManager.Base.applicationSupportDirectory
            .appending(
                component: "/\(Constant.crashFilePrefix)\(timestamp).json"
            )
        do {
            let data = try JSONEncoder.parraEncoder.encode(crashInfo)

            try data.write(
                to: crashReportPath,
                options: .noFileProtection
            )
        } catch {
            Logger.fatal("Failed to create crash report", error)
        }
    }
}
