//
//  Thread.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

extension Thread {

    /// Gets the name and number of the thread. It is possible that the number will change,
    /// but could potentially be useful tracing information used in combination with the pthread id.
    /// Name might only exist for the main thread but more testing is needed.
    ///
    /// It would also be nice to not have to parse this, but the only alternative option is currently
    /// to access private fields on NSThread via valueForKey.
    var threadNameAndNumber: (String?, UInt8)? {
        // Example of what we're parsing.
        // "<NSThread: 0x11358ba00>{number = 11, name = (null)}"
        // This is really annoying because name and number could be in either order.

        if isMainThread {
            return ("main", 1)
        }

        let components = description.split(separator: "{")
        guard let end = components.last?.dropLast(), components.count == 2 else {
            return nil
        }

        let subComponents = end.components(separatedBy: ", ")
        guard subComponents.count == 2 else {
            // There are more properties that we weren't aware of
            // This could eventually be handled by enumerating the subComponents array
            // and checking prefixes before the = for known keys.
            return nil
        }

        guard let dividerRange = end.range(of: ", ") else {
            return nil
        }

        let numPrefix = "number = "
        guard let numPrefixEndIdx = end.range(of: numPrefix)?.upperBound else {
            return nil
        }

        let threadNumber: UInt8?
        let isNameFirst: Bool
        if numPrefixEndIdx < dividerRange.lowerBound {
            // number was first
            let numberString = end[numPrefixEndIdx..<dividerRange.lowerBound]
            threadNumber = UInt8(numberString)
            isNameFirst = false
        } else {
            // number was second
            let numberString = end[numPrefixEndIdx...]
            threadNumber = UInt8(numberString)
            isNameFirst = true
        }

        guard let threadNumber else {
            return nil
        }

        let threadName: String?
        if let name, !name.isEmpty {
            threadName = name
        } else {
            let namePrefix = "name = "

            if let namePrefixEndIdx = end.range(of: namePrefix)?.upperBound {
                let foundName: String.SubSequence
                if isNameFirst {
                    foundName = end[namePrefixEndIdx..<dividerRange.lowerBound]
                } else {
                    foundName = end[namePrefixEndIdx...]
                }

                threadName = foundName == "(null)" ? nil : String(foundName)
            } else {
                threadName = nil
            }
        }

        return (threadName, threadNumber)
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
