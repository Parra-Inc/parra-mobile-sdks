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
@Observable
public final class ParraMetadata: Codable, Equatable, Hashable,
    ParraReadableKeyValueStore
{
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

    public internal(set) var rawValue: [String: ParraAnyCodable]

    public static func == (lhs: ParraMetadata, rhs: ParraMetadata) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = try encoder.singleValueContainer()

        try container.encode(rawValue)
    }

    public func `as`<T>(_ type: T.Type) -> T? where T: Decodable & Equatable {
        do {
            // Being really explicity here so that this doesn't infinitely
            // recurse on the non-throwing variant.
            let result: T = try self.as(type.self) as T

            return result
        } catch {
            return nil
        }
    }

    public func `as`<T>(_ type: T.Type) throws -> T where T: Decodable & Equatable {
        let data = try JSONEncoder.parraEncoder.encode(rawValue)

        return try JSONDecoder.parraDecoder.decode(T.self, from: data)
    }

    public func hasValue(for key: String) -> Bool {
        let result = rawValue[key] != nil

        logger.trace("Metadata has value for key: \(key) -> \(result)")

        return result
    }
}
