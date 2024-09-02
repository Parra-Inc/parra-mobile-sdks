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

#if DEBUG
// Can't work in production. Undefined behavior to do async actions within it
// and many other things once a signal has already been raised.
private let logger = Logger()
#endif

// Global function to handle uncaught exceptions
func parraExceptionHandler(_ exception: NSException) {
    ExceptionHandler.log("ExceptionHandler: parraExceptionHandler")

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
        log("ExceptionHandler: addSignalListeners")

        for signal in signals {
            existingSignalHandlers[signal] = Darwin.signal(signal) { signalReceived in
                Darwin.signal(signalReceived, ExceptionHandler.handleSignal)
            }
        }
    }

    /// CAN NOT BE CALLED MORE THAN ONCE.
    static func addExceptionHandlers() {
        log("ExceptionHandler: addExceptionHandlers")

        existingHandler = NSGetUncaughtExceptionHandler()

        NSSetUncaughtExceptionHandler(parraExceptionHandler)
    }

    static func handleUncaughtException(
        _ exception: NSException
    ) {
        log("ExceptionHandler: handleUncaughtException")

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

    // MARK: - Fileprivate

    fileprivate static func log(_ message: String) {
        #if DEBUG
        logger.debug(message)
        #endif
    }

    // MARK: - Private

    // Reference the existing handler, so that we don't override crash reporting
    // libraries that the developer may be using. This will be invoked after our own
    // crash handler.
    private static var existingHandler: NSUncaughtExceptionHandler?
    private static var existingSignalHandlers: [
        Int32: @convention(c) (Int32) -> Void
    ] = [:]
    private static var currentSessionId: String?

    private static let handleSignal: @convention(c) (Int32) -> Void = {
        signal in

        let frames = CallStackParser.backtrace().frameStrings
        let signalName = name(of: signal)
        let reason = "Signal \(signalName)(\(signal)) was raised.\n"

        log("ExceptionHandler: handleSignal \(signalName)")

        let crash = CrashInfo(
            sessionId: currentSessionId,
            type: .signal,
            name: signalName,
            reason: reason,
            callStack: frames
        )

        persistCrash(crash)

        // Remove our custom handler
        Darwin.signal(signal, SIG_DFL)

        // If there was a previous handler, call it
        if let previousHandler = existingSignalHandlers[signal] {
            previousHandler(signal)
        }

        // If we somehow get here, forcibly exit
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
                component: "\(Constant.crashFilePrefix)\(timestamp).json"
            )

        log("ExceptionHandler: persistCrash \(crashReportPath.absoluteString)")

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

//
// int ksmach_machExceptionForSignal(const int sigNum)
// {
//    switch(sigNum)
//    {
//    case SIGFPE:
//        return EXC_ARITHMETIC;
//    case SIGSEGV:
//        return EXC_BAD_ACCESS;
//    case SIGBUS:
//        return EXC_BAD_ACCESS;
//    case SIGILL:
//        return EXC_BAD_INSTRUCTION;
//    case SIGTRAP:
//        return EXC_BREAKPOINT;
//    case SIGEMT:
//        return EXC_EMULATION;
//    case SIGSYS:
//        return EXC_UNIX_BAD_SYSCALL;
//    case SIGPIPE:
//        return EXC_UNIX_BAD_PIPE;
//    case SIGABRT:
//        // The Apple reporter uses EXC_CRASH instead of EXC_UNIX_ABORT
//        return EXC_CRASH;
//    case SIGKILL:
//        return EXC_SOFT_SIGNAL;
//    }
//    return 0;
// }
