//
//  ParraUserProperties.swift
//
//
//  Created by Mick MacCallum on 9/21/24.
//

import SwiftUI

private let logger = ParraLogger(category: "Parra User Properties")
private let maxKeyLength = 128
private let maxStringValueLength = 1_024

@Observable
public final class ParraUserProperties: Codable, PrimitiveObjectAccess {
    // MARK: - Public

    public internal(set) var rawValue: [String: ParraAnyCodable] = [:]

    public func set(_ value: String, for key: String) {
        withValidStringValue(value, for: key) { validValue in
            set(validValue, for: key)
        }
    }

    public func set(_ int: Int, for key: String) {
        set(bool, for: key)
    }

    public func set(_ int: Int, for key: String) async throws {
        set(bool, for: key)
    }

    public func set(_ float: Float, for key: String) {
        set(bool, for: key)
    }

    public func set(_ double: Double, for key: String) {
        set(bool, for: key)
    }

    public func set(_ bool: Bool, for key: String) {
        set(bool, for: key)
    }

    // MARK: - Internal

    static let `default` = ParraUserProperties()

    // MARK: - Private

    private func set(_ value: Any, for key: String) {
        withValidKey(key) { validKey in
            rawValue[validKey] = ParraAnyCodable(value)
        }
    }

    private func stuff() async {
        let api = await Parra.default.parraInternal.api
    }

    private func withValidKey(
        _ key: String,
        _ execute: (String) -> Void
    ) {
        guard key.count < maxKeyLength else {
            logger.error("Key is too long. Must be less than 128 characters.", [
                "key": key
            ])

            return
        }

        execute(key)
    }

    private func withValidStringValue(
        _ value: String,
        for key: String,
        _ execute: (String) -> Void
    ) {
        guard value.count < maxStringValueLength else {
            logger.error(
                "Value for key is too long. Must be less than 1024 characters.",
                [
                    "key": key,
                    "value": value
                ]
            )

            return
        }

        execute(value)
    }
}

// - No more than 100
//    - each key must be less than 128 chars
//    - each string value must be less than 1024 chars
// - No arrays initially, no objects initially
// - is NSUserDefaults
// - read / write key value store from —
// - limit on size
