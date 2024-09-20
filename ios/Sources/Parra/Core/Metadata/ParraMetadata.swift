//
//  ParraMetadata.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import Combine
import SwiftUI

private let logger = Logger(category: "Parra Metadata")

/// A wrapper around an objects metadata. It allows for direct access to the
/// metadata dictionary, as well as convenience methods for accessing values.
public struct ParraMetadata: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(rawValue: [String: ParraAnyCodable]? = nil) {
        self.rawValue = rawValue ?? [:]
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.singleValueContainer()

        do {
            self.rawValue = try container.decode([String: ParraAnyCodable].self)
        } catch {
            self.rawValue = [:]
        }
    }

    // MARK: - Public

    public let rawValue: [String: ParraAnyCodable]

    public func encode(to encoder: any Encoder) throws {
        var container = try encoder.singleValueContainer()

        try container.encode(rawValue)
    }

    public func hasValue(for key: String) -> Bool {
        let result = rawValue[key] != nil

        logger.trace("Metadata has value for key: \(key) -> \(result)")

        return result
    }

    public func string(for key: String) -> String? {
        return value(for: key)
    }

    public func int(for key: String) -> Int? {
        return value(for: key)
    }

    public func float(for key: String) -> Float? {
        return value(for: key)
    }

    public func double(for key: String) -> Double? {
        return value(for: key)
    }

    public func bool(for key: String) -> Bool? {
        return value(for: key)
    }

    public func value(for key: String) -> Any? {
        return rawValue[key]?.value
    }

    public func string<Key>(
        for key: Key
    ) -> String? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    public func int<Key>(
        for key: Key
    ) -> Int? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    public func float<Key>(
        for key: Key
    ) -> Float? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    public func double<Key>(
        for key: Key
    ) -> Double? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    public func bool<Key>(
        for key: Key
    ) -> Bool? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    public func value<Key>(
        for key: Key
    ) -> Any? where Key: RawRepresentable, Key.RawValue == String {
        return rawValue[key.rawValue]?.value
    }

    public func value<T>(for key: String) -> T? {
        return rawValue[key]?.value as? T
    }

    public func value<T, Key>(
        for key: Key
    ) -> T? where Key: RawRepresentable, Key.RawValue == String {
        return rawValue[key.rawValue]?.value as? T
    }
}
