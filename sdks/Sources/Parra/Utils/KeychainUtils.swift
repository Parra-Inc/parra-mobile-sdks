//
//  KeychainUtils.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum KeychainUtils {
    static func performSecOperation(
        _ op: () -> OSStatus
    ) throws {
        let status = op()

        if status != errSecSuccess {
            throw error(for: status)
        }
    }

    static func error(for status: OSStatus) -> ParraError {
        let message = SecCopyErrorMessageString(status, nil) as String?
            ?? "unknown keychain error"

        return ParraError.message("Keychain error: \(message)")
    }
}
