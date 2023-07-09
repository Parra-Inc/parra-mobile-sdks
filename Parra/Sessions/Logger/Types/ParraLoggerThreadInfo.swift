//
//  ParraLoggerThreadInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerThreadInfo {
    public let id: Int
    public let name: String
    public let queueName: String
    public let stackSize: Int
    public let priority: Double // 0.0...1.0
    public let qualityOfService: QualityOfService
    public let callStackSymbols: [String]?
    public let callStackReturnAddresses: [UInt]?

    public init(
        thread: Thread,
        captureCallStack: Bool = false
    ) {
        self.id = thread.threadId
        self.name = thread.threadName
        self.queueName = thread.queueName
        self.stackSize = thread.stackSize
        self.priority = thread.threadPriority
        self.qualityOfService = thread.qualityOfService

        // TODO: Capture current OperationQueue state?

        if captureCallStack {
            self.callStackSymbols = Thread.callStackSymbols
            self.callStackReturnAddresses = Thread.callStackReturnAddresses.map {
                $0.uintValue
            }
        } else {
            self.callStackSymbols = nil
            self.callStackReturnAddresses = nil
        }
    }
}
