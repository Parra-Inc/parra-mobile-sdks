//
//  KeychainStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import Security

actor KeychainStorage: PersistentStorageMedium, @unchecked Sendable {
    // MARK: - Lifecycle

    init(
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    // MARK: - Internal

    struct PasswordWrapper: Codable {
        let password: String
    }

    nonisolated func read<T>(
        name: String
    ) throws -> T? where T: Codable {
        var query = commonQueryAttributes(for: name)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true

        var item: CFTypeRef?

        try? performSecOperation {
            SecItemCopyMatching(query as CFDictionary, &item)
        }

        if let existingItem = item as? [String: Any],
           let data = existingItem[kSecValueData as String] as? Data
        {
            return try jsonDecoder.decode(T.self, from: data)
        }

        return nil
    }

    nonisolated func write(
        name: String,
        value: some Codable
    ) throws {
        let data = try jsonEncoder.encode(value)

        let attributes: [String: Any] = [kSecValueData as String: data]
        let query = commonQueryAttributes(for: name)

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        // Can't update an entry if it doesn't exist yet. Have to explicitly
        // add it first.

        if updateStatus == errSecItemNotFound {
            let newItem = query.merging(attributes, uniquingKeysWith: { $1 })
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)

            if addStatus == errSecSuccess {
                return
            } else {
                throw error(for: addStatus)
            }
        } else {
            throw error(for: updateStatus)
        }
    }

    nonisolated func delete(
        name: String
    ) throws {
        let query = commonQueryAttributes(for: name)

        try performSecOperation {
            SecItemDelete(query as CFDictionary)
        }
    }

    // MARK: - Private

    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    private nonisolated func commonQueryAttributes(
        for key: String
    ) -> [String: Any] {
        let name = "parra_\(key)"

        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name
        ]
    }

    private nonisolated func performSecOperation(
        _ op: () -> OSStatus
    ) throws {
        let status = op()

        if status != errSecSuccess {
            throw error(for: status)
        }
    }

    private nonisolated func error(for status: OSStatus) -> ParraError {
        let message = SecCopyErrorMessageString(status, nil) as String?
            ?? "unknown keychain error"

        return ParraError.message("Keychain error: \(message)")
    }
}
