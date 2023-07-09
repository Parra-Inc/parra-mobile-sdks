//
//  Thread.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

extension Thread {
    var threadName: String {
        if isMainThread {
            return "main"
        } else if let threadName = name, !threadName.isEmpty {
            return threadName
        } else {
            return description
        }
    }

    var threadId: Int {
        return Int(pthread_mach_thread_np(pthread_self()))
    }

    var queueName: String {
        if let queueName = String(
            validatingUTF8: __dispatch_queue_get_label(nil)
        ) {
            return queueName
        } else if let operationQueueName = OperationQueue.current?.name,
                    !operationQueueName.isEmpty {
            return operationQueueName
        } else if let dispatchQueueName = OperationQueue.current?.underlyingQueue?.label,
                    !dispatchQueueName.isEmpty {
            return dispatchQueueName
        } else {
            return "n/a"
        }
    }
}
