//
//  CallStackParser.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import Darwin

fileprivate typealias Swift_Demangle = @convention(c) (
    _ mangledName: UnsafePointer<UInt8>?,
    _ mangledNameLength: Int,
    _ outputBuffer: UnsafeMutablePointer<UInt8>?,
    _ outputBufferSize: UnsafeMutablePointer<Int>?,
    _ flags: UInt32
) -> UnsafeMutablePointer<Int8>?

// TODO: ! Important: this is crazy and not cool. This is supported on iOS 12+ but we need
// find a safer way to access it.
// TODO: When doing crash handlers for real, note that it is undefined behavior to malloc after SIGKILL
//       in this case it is important to use backtrace_symbols_fd to write the symbols to a file to be
//       read on the next app launch.
// https://github.com/getsentry/sentry-cocoa/issues/1919#issuecomment-1360987627

@_silgen_name("backtrace")
fileprivate func backtrace(_: UnsafeMutablePointer<UnsafeMutableRawPointer?>!, _: UInt32) -> UInt32

// https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report/

internal struct CallStackParser {
    internal static func parse(frames: [String], discardParraFrames: Bool) -> [CallStackFrame] {
        return frames.compactMap { frame in
            let replaced = frame.replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )

            let components = replaced.components(separatedBy: .whitespaces)
            assert(components.count >= 6 || components.count <= 8, "Unknown stack frame format: \(frame)")

            let binaryName = components[1]
            // TODO: Need a way to do this that doesn't throw out all the frames for logs that originate within Parra.
//            if discardParraFrames && binaryName.caseInsensitiveCompare(Parra.name) == .orderedSame {
//                return nil
//            }

            guard let frameNumber = UInt8(components[0]),
                  let address = UInt64(components[2].dropFirst(2), radix: 16) else {
                return nil
            }

            guard let plusIndex = components.firstIndex(of: "+"), plusIndex >= 4 else {
                return nil
            }

            guard let byteOffset = UInt16(components[plusIndex + 1]) else {
                return nil
            }

            let symbol = components[3...(plusIndex - 1)].joined(separator: " ")

            var fileInfo: (String, UInt8)?
            if let last = components.last, last.starts(with: "("), components.count == plusIndex + 3 {
                let trimmed = last.trimmingCharacters(in: .punctuationCharacters)

                let fileComponents = trimmed.split(separator: ":")

                if let name = fileComponents.first,
                   let lineString = fileComponents.last,
                   let line = UInt8(lineString),
                   fileComponents.count == 2 {

                    fileInfo = (String(name), line)
                }
            }

            guard let demangledSymbol = demangle(symbol: symbol) else {
                return nil
            }

            return CallStackFrame(
                frameNumber: frameNumber,
                binaryName: binaryName,
                address: address,
                symbol: demangledSymbol,
                byteOffset: byteOffset,
                fileName: fileInfo?.0,
                lineNumber: fileInfo?.1
            )
        }
    }

    internal static func demangle(symbol mangled: String) -> String? {
        let RTLD_DEFAULT = dlopen(nil, RTLD_NOW)

        guard let sym = dlsym(RTLD_DEFAULT, "swift_demangle") else {
            return nil
        }


        let f = unsafeBitCast(sym, to: Swift_Demangle.self)
        guard let cString = f(mangled, mangled.count, nil, nil, 0) else {
            return nil
        }

        defer {
            cString.deallocate()
        }

        return String(cString: cString)
    }

//    internal static func addSigKillHandler() {
//        setupHandler(for: SIGKILL) { _ in
//            // this is all undefined behaviour, not allowed to malloc or call backtrace here...
//
//            let maxFrames = 50
//            let stackSymbols: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = .allocate(capacity: maxFrames)
//            stackSymbols.initialize(repeating: nil)
//            let howMany = backtrace(stackSymbols.baseAddress!, UInt32(CInt(maxFrames)))
//            let ptr = backtrace_symbols(stackSymbols.baseAddress!, howMany)
//            let realAddresses = Array(UnsafeBufferPointer(start: ptr, count: Int(howMany))).compactMap { $0 }
//            realAddresses.forEach {
//                print(String(cString: $0))
//            }
//        }
//    }
//
//    internal static func setupHandler(
//        for signal: Int32,
//        handler: @escaping @convention(c) (CInt) -> Void
//    ) {
//        typealias SignalAction = sigaction
//
//        let flags = CInt(SA_NODEFER) | CInt(bitPattern: CUnsignedInt(SA_RESETHAND))
//        var signalAction = SignalAction(
//            __sigaction_u: unsafeBitCast(handler, to: __sigaction_u.self),
//            sa_mask: sigset_t(),
//            sa_flags: flags
//        )
//
//        withUnsafePointer(to: &signalAction) { ptr in
//            sigaction(signal, ptr, nil)
//        }
//    }
}
