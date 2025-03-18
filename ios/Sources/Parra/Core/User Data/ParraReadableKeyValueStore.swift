//
//  ParraReadableKeyValueStore.swift
//
//
//  Created by Mick MacCallum on 9/22/24.
//

import Foundation

public protocol ParraReadableKeyValueStore {
    var rawValue: [String: ParraAnyCodable] { get }
}

public extension ParraReadableKeyValueStore {
    @MainActor
    func string(for key: String) -> String? {
        return value(for: key)
    }

    @MainActor
    func int(for key: String) -> Int? {
        return number(for: key)?.intValue
    }

    @MainActor
    func double(for key: String) -> Double? {
        return number(for: key)?.doubleValue
    }

    @MainActor
    func bool(for key: String) -> Bool {
        return number(for: key)?.boolValue ?? false
    }

    @MainActor
    func number(for key: String) -> NSNumber? {
        return value(for: key)
    }

    @MainActor
    func value(for key: String) -> Any? {
        return rawValue[key]?.value
    }

    @MainActor
    func string<Key>(
        for key: Key
    ) -> String? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    @MainActor
    func int<Key>(
        for key: Key
    ) -> Int? where Key: RawRepresentable, Key.RawValue == String {
        return number(for: key.rawValue)?.intValue
    }

    @MainActor
    func double<Key>(
        for key: Key
    ) -> Double? where Key: RawRepresentable, Key.RawValue == String {
        return number(for: key.rawValue)?.doubleValue
    }

    @MainActor
    func bool<Key>(
        for key: Key
    ) -> Bool? where Key: RawRepresentable, Key.RawValue == String {
        return number(for: key.rawValue)?.boolValue
    }

    @MainActor
    func number<Key>(
        for key: Key
    ) -> NSNumber? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    @MainActor
    func value<Key>(
        for key: Key
    ) -> Any? where Key: RawRepresentable, Key.RawValue == String {
        return rawValue[key.rawValue]?.value
    }

    @MainActor
    func value<T>(for key: String) -> T? {
        return rawValue[key]?.value as? T
    }

    @MainActor
    func value<T, Key>(
        for key: Key
    ) -> T? where Key: RawRepresentable, Key.RawValue == String {
        return rawValue[key.rawValue]?.value as? T
    }
}
