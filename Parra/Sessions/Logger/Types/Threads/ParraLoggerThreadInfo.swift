//
//  ParraLoggerThreadInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@usableFromInline
internal struct ParraLoggerThreadInfo: Codable {
    public let id: Int
    public let queueName: String
    public let stackSize: Int
    public let priority: Double // 0.0...1.0
    public let qualityOfService: QualityOfService
    public let threadName: String?
    public let threadNumber: UInt8?
    internal private(set) var callStackSymbols: ParraLoggerStackSymbols

    @usableFromInline
    internal init(
        thread: Thread,
        callStackSymbols: ParraLoggerStackSymbols = .none
    ) {
        self.id = thread.threadId
        self.queueName = thread.queueName
        self.stackSize = thread.stackSize
        self.priority = thread.threadPriority
        self.qualityOfService = thread.qualityOfService
        self.callStackSymbols = callStackSymbols

        if let (threadName, threadNumber) = thread.threadNameAndNumber {
            self.threadName = threadName
            self.threadNumber = threadNumber
        } else {
            self.threadName = nil
            self.threadNumber = nil
        }
    }

    /// Demangles the call stack symbols and stores them in place of the raw symbols, if symbols
    /// exist and they haven't already been demangled.
    mutating internal func demangleCallStack() {
        switch callStackSymbols {
        case .raw(let frames):
            let demangledFrames = CallStackParser.parse(
                frames: frames
            )

            self.callStackSymbols = .demangled(demangledFrames)
        case .demangled, .none:
            break
        }
    }
}
