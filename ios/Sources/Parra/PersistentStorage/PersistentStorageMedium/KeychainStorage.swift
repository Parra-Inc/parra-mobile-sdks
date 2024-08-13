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
        query[kSecReturnData as String] = true

        var item: CFTypeRef?

        try performSecOperation {
            SecItemCopyMatching(query as CFDictionary, &item)
        }

        if let data = item as? Data {
            return try jsonDecoder.decode(T.self, from: data)
        }

        return nil
    }

    nonisolated func write(
        name: String,
        value: some Codable
    ) throws {
        let data = try jsonEncoder.encode(value)

        let commonQuery = commonQueryAttributes(for: name)
        var addQuery = commonQuery
        addQuery[kSecValueData as String] = data as AnyObject

        let addStatus = SecItemAdd(
            addQuery as CFDictionary,
            nil
        )

        if addStatus == errSecSuccess {
            return
        }

        // If the item already existed, continue and update it instead.
        // Otherwise, the status code was unexepected, throw an error.
        if addStatus != errSecDuplicateItem {
            throw error(for: addStatus)
        }

        let attributes: [String: AnyObject] = [
            kSecValueData as String: data as AnyObject
        ]

        // SecItemUpdate attempts to update the item identified
        // by query, overriding the previous value
        let updateStatus = SecItemUpdate(
            commonQuery as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        throw error(for: updateStatus)
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
        let account = "parra_\(key)"

        guard let appBundleId = ParraInternal.appBundleIdentifier(
            bundle: .main
        ) else {
            fatalError("Couldn't obtain app bundle id")
        }

        return [
            kSecAttrService as String: appBundleId as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
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
