//
//  CallStackFrame.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// Field definitions from [Apple documentation(https://developer.apple.com/documentation/xcode/examining-the-fields-in-a-crash-report#Backtraces)
@usableFromInline
struct CallStackFrame: Codable {
    /// The stack frame number. Stack frames are in calling order, where frame 0 is the function that
    /// was executing at the time execution halted. Frame 1 is the function that called the
    /// function in frame 0, and so on.
    let frameNumber: UInt8

    /// The name of the binary containing the function that is executing.
    let binaryName: String

    /// The address of the machine instruction that is executing. For frame 0 in each backtrace, this is the
    /// address of the machine instruction executing on a thread when the process terminated. For other stack
    /// frames, this is the address of first machine instruction that executes after control returns to that
    /// stack frame.
    let address: UInt64

    /// The name of the function that is executing.
    let symbol: String

    /// The byte offset from the function’s entry point to the current instruction in the function.
    let byteOffset: UInt16

    /// The file name and line number containing the code, if you have a dSYM file for the binary.
    let fileName: String?
    let lineNumber: UInt8?
}
