//
//  PrimitiveObjectAccess.swift
//
//
//  Created by Mick MacCallum on 9/22/24.
//

import Foundation

public protocol PrimitiveObjectAccess {
    var rawValue: [String: ParraAnyCodable] { get }
}

public extension PrimitiveObjectAccess {
    func string(for key: String) -> String? {
        return value(for: key)
    }

    func int(for key: String) -> Int? {
        return value(for: key)
    }

    func float(for key: String) -> Float? {
        return value(for: key)
    }

    func double(for key: String) -> Double? {
        return value(for: key)
    }

    func bool(for key: String) -> Bool? {
        return value(for: key)
    }

    func value(for key: String) -> Any? {
        return rawValue[key]?.value
    }

    func string<Key>(
        for key: Key
    ) -> String? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    func int<Key>(
        for key: Key
    ) -> Int? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    func float<Key>(
        for key: Key
    ) -> Float? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    func double<Key>(
        for key: Key
    ) -> Double? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    func bool<Key>(
        for key: Key
    ) -> Bool? where Key: RawRepresentable, Key.RawValue == String {
        return value(for: key.rawValue)
    }

    func value<Key>(
        for key: Key
    ) -> Any? where Key: RawRepresentable, Key.RawValue == String {
        return rawValue[key.rawValue]?.value
    }

    func value<T>(for key: String) -> T? {
        return rawValue[key]?.value as? T
    }

    func value<T, Key>(
        for key: Key
    ) -> T? where Key: RawRepresentable, Key.RawValue == String {
        return rawValue[key.rawValue]?.value as? T
    }
}
