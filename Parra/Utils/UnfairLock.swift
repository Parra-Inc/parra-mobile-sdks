//
//  UnfairLock.swift
//  Parra
//
//  Created by Mick MacCallum on 9/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Remove and replace with OSAllocatedUnfairLock when deployment target is iOS 16+
// https://developer.apple.com/documentation/os/osallocatedunfairlock

final class UnfairLock {
    private var _lock: UnsafeMutablePointer<os_unfair_lock>
    
    init() {
        _lock = UnsafeMutablePointer<os_unfair_lock>.allocate(
            capacity: 1
        )
        
        _lock.initialize(
            to: os_unfair_lock()
        )
    }
    
    deinit {
        _lock.deallocate()
    }
    
    func locked<ReturnValue>(
        _ handler: () throws -> ReturnValue
    ) rethrows -> ReturnValue {
        os_unfair_lock_lock(_lock)
        
        defer {
            os_unfair_lock_unlock(_lock)
        }
        
        return try handler()
    }
}
