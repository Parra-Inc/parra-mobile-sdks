//
//  Trace.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct StackFrame {
    let symbol: String
    let file: String
    let address: UInt64
    let symbolAddress: UInt64

    var demangledSymbol: String {
        return _stdlib_demangleName(symbol)
    }
}

struct StackTrace {
    static var frames: [StackFrame] {
        var symbols = [StackFrame]()
        let stackSize: UInt32 = 256
        let addrs = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: Int(stackSize))
        defer { addrs.deallocate() }
        let frameCount = backtrace(addrs, stackSize)
        let buf = UnsafeBufferPointer(start: addrs, count: Int(frameCount))
        for addr in buf {
            guard let addr = addr else { continue }
            let dlInfoPtr = UnsafeMutablePointer<Dl_info>.allocate(capacity: 1)
            defer { dlInfoPtr.deallocate() }
            guard dladdr(addr, dlInfoPtr) != 0 else {
                continue
            }
            let info = dlInfoPtr.pointee
            let symbol = String(cString: info.dli_sname)
            let filename = String(cString: info.dli_fname)
            let symAddrValue = unsafeBitCast(info.dli_saddr, to: UInt64.self)
            let addrValue = UInt64(UInt(bitPattern: addr))
            symbols.append(StackFrame(symbol: symbol, file: filename, address: addrValue, symbolAddress: symAddrValue))
        }
        return symbols
    }
}

/// Here be dragons! _stdlib_demangleImpl is linked into the stdlib. Use at your own risk!

@_silgen_name("swift_demangle")
public
func _stdlib_demangleImpl(
    mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
) -> UnsafeMutablePointer<CChar>?

func _stdlib_demangleName(_ mangledName: String) -> String {
    return mangledName.utf8CString.withUnsafeBufferPointer {
        (mangledNameUTF8CStr) in

        let demangledNamePtr = _stdlib_demangleImpl(
            mangledName: mangledNameUTF8CStr.baseAddress,
            mangledNameLength: UInt(mangledNameUTF8CStr.count - 1),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: 0)

        if let demangledNamePtr = demangledNamePtr {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return mangledName
    }
}

/// backtrace is included on macOS and Linux, with the same ABI.
@_silgen_name("backtrace")
fileprivate func backtrace(_: UnsafeMutablePointer<UnsafeMutableRawPointer?>!, _: UInt32) -> UInt32
