//
//  CallStackParser.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Darwin
import Foundation

private let logger = Logger(
    bypassEventCreation: true,
    category: "Symbolication"
)

private typealias Swift_Demangle = @convention(c) (
    _ mangledName: UnsafePointer<UInt8>?,
    _ mangledNameLength: Int,
    _ outputBuffer: UnsafeMutablePointer<UInt8>?,
    _ outputBufferSize: UnsafeMutablePointer<Int>?,
    _ flags: UInt32
) -> UnsafeMutablePointer<Int8>?

// https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report/

enum CallStackParser {
    // MARK: - Internal

    static func parse(
        frames: [String]
    ) -> [CallStackFrame] {
        return frames.compactMap { (frame: String) -> CallStackFrame? in
            let components = frame.split { char in
                return char.isWhitespace || char.isNewline
            }

            assert(
                components.count >= 6 || components.count <= 8,
                "Unknown stack frame format: \(frame)"
            )

            guard let frameNumber = UInt8(components[0]),
                  let address = UInt64(components[2].dropFirst(2), radix: 16) else {
                return nil
            }

            guard let plusIndex = components.firstIndex(of: "+"),
                  plusIndex >= 4 else
            {
                return nil
            }

            guard let byteOffset = UInt64(components[plusIndex + 1]) else {
                return nil
            }

            let rawSymbol = components[3 ... (plusIndex - 1)]
                .joined(separator: " ")

            var fileInfo: (String, UInt8)?
            if let last = components.last, last.starts(with: "("),
               components.count == plusIndex + 3
            {
                let trimmed = last
                    .trimmingCharacters(in: .punctuationCharacters)

                let fileComponents = trimmed.split(separator: ":")

                if let name = fileComponents.first,
                   let lineString = fileComponents.last,
                   let line = UInt8(lineString),
                   fileComponents.count == 2
                {
                    fileInfo = (String(name), line)
                }
            }

            let symbol = demangleSymbolIfNeeded(symbol: rawSymbol)
            let binaryName = String(components[1])

            return CallStackFrame(
                frameNumber: frameNumber,
                binaryName: binaryName,
                address: address,
                symbol: symbol,
                byteOffset: byteOffset,
                fileName: fileInfo?.0,
                lineNumber: fileInfo?.1
            )
        }
    }

    static func printBacktrace() {
        let symbols = backtrace()

        logger.info(symbols.frameStrings.joined(separator: "\n"))
    }

    static func backtrace(
        stackSize: Int = 16
    ) -> ParraLoggerStackSymbols {
        let addresses = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(
            capacity: stackSize
        )

        defer {
            addresses.deallocate()
        }

        let frameCount = backtrace_async(addresses, Int(stackSize), nil)
        let buffer = UnsafeBufferPointer(
            start: addresses,
            count: Int(frameCount)
        )

        let stackFrames: [CallStackFrame] = buffer.enumerated()
            .compactMap { index, address in
                guard let address else {
                    return nil
                }

                let dlInfoPrt = UnsafeMutablePointer<Dl_info>.allocate(
                    capacity: 1
                )

                defer {
                    dlInfoPrt.deallocate()
                }

                guard dladdr(address, dlInfoPrt) != 0 else {
                    return nil
                }

                let info = dlInfoPrt.pointee

                // Name of nearest symbol
                let rawSymbol = String(cString: info.dli_sname)
                // Pathname of shared object
                let fileName = String(cString: info.dli_fname)
                // Address of nearest symbol
                let symbolAddressValue = unsafeBitCast(
                    info.dli_saddr,
                    to: UInt64.self
                )

                let addressValue = UInt64(UInt(bitPattern: address))

                let symbol = demangleSymbolIfNeeded(symbol: rawSymbol)

                // TODO: Review these values
                return CallStackFrame(
                    frameNumber: UInt8(index),
                    binaryName: "",
                    address: symbolAddressValue,
                    symbol: symbol,
                    byteOffset: addressValue,
                    fileName: fileName,
                    lineNumber: nil
                )
            }

        return .demangled(stackFrames)
    }

    // TODO: When doing crash handlers for real, note that it is undefined behavior to malloc after SIGKILL
    //       in this case it is important to use backtrace_symbols_fd to write the symbols to a file to be
    //       read on the next app launch.
    // https://github.com/getsentry/sentry-cocoa/issues/1919#issuecomment-1360987627

    //    @_silgen_name("backtrace")
    //    fileprivate func backtrace(_: UnsafeMutablePointer<UnsafeMutableRawPointer?>!, _: UInt32) -> UInt32
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

    // MARK: - Fileprivate

    fileprivate enum Constant {
        /// In order by expected likelihood that they'll be encountered
        /// https://github.com/apple/swift/blob/b5ddffdb3d095e4a57abaac3f8c1e327d64ebea1/lib/Demangling/Demangler.cpp#L181-L184
        #if swift(>=5.0)
        static let swiftSymbolPrefixes = [
            // Swift 5+
            "$s", "_$s",
            // Swift 5+ for filenames
            "@__swiftmacro_"
        ]
        #elseif swift(>=4.1)
        static let swiftSymbolPrefixes = [
            // Swift 4.x
            "$S", "_$S"
        ]
        #else
        static let swiftSymbolPrefixes = [
            // Swift 4
            "_T0"
        ]
        #endif
    }

    // MARK: - Private

    private static func demangleSymbolIfNeeded(
        symbol: String
    ) -> String {
        if symbol.hasAnyPrefix(Constant.swiftSymbolPrefixes) {
            // Swift symbols need to be demangled. Failing to demangle should at least
            // return the raw symbol.
            return demangle(symbol: symbol) ?? symbol
        }

        // Objective-C symbols do not need to be demangled. It is also possible that a symbol
        // is unsymbolicated, in which case it will be a memory address. C++ can also require
        // symbolication, but that's for another day.

        return symbol
    }

    /// 🤞 https://github.com/apple/swift-evolution/blob/main/proposals/0262-demangle.md
    private static func demangle(symbol mangled: String) -> String? {
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
}
