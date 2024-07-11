//
//  ExceptionHandler.swift
//  Sample
//
//  Created by Mick MacCallum on 7/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Dispatch
import Foundation
import ObjectiveC

// Reference the existing handler, so that we don't override crash reporting
// libraries that the developer may be using. This will be invoked after our own
// crash handler.
let existingHandler = NSGetUncaughtExceptionHandler()

enum ExceptionHandler {
    // MARK: - Internal

    static let signals: [Int32] = [
        SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE, SIGTRAP
    ]

    static func addSignalListeners() {
        for sig in signals {
            signal(sig, ExceptionHandler.handleSignal)
        }
    }

    static func addExceptionHandlers() {
        NSSetUncaughtExceptionHandler { exception in
            ExceptionHandler.handleUncaughtException(exception)

            // Invoke the existing handler.
            existingHandler?(exception)
        }
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
            type: .exception,
            name: exception.name.rawValue,
            reason: exception.reason ?? "",
            callStack: frames
        )

        persistCrash(crash)
    }

    // MARK: - Private

    private static let handleSignal: @convention(c) (Int32) -> Void = {
        signal in

        var frames = CallStackParser.backtrace().frameStrings
        frames.removeFirst(3)

        let signalName = name(of: signal)
        let reason = "Signal \(signalName)(\(signal)) was raised.\n"

        let crash = CrashInfo(
            type: .signal,
            name: signalName,
            reason: reason,
            callStack: frames
        )

        persistCrash(crash)
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
        let crashReportPath = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask,
            true
        ).first!.appending("/parra-crash-report-\(timestamp).txt")

        do {
            let data = try JSONEncoder.parraEncoder.encode(crashInfo)
            let dataString = String(data: data, encoding: .utf8)!

            crashReportPath.withCString { pathPtr in
                dataString.withCString { dataPtr in
                    writeCrashInfo(
                        pathPtr,
                        dataPtr
                    )
                }
            }
        } catch {
            Logger.fatal("Failed to create crash report", error)
        }

        killApp()
    }

    private static func killApp() {
        NSSetUncaughtExceptionHandler(nil)

        for sig in signals {
            signal(sig, SIG_DFL)
        }

        kill(getpid(), SIGKILL)
    }
}
