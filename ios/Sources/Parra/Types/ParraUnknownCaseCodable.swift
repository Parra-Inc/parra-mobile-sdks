//
//  ParraUnknownCaseCodable.swift
//  Parra
//
//  Created by Mick MacCallum on 10/25/24.
//

import Foundation

public protocol ParraUnknownCaseCodable: RawRepresentable,
    Codable where RawValue: Codable
{
    static var unknown: Self { get }
}

public extension ParraUnknownCaseCodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedValue = try container.decode(RawValue.self)
        self = Self(rawValue: decodedValue) ?? Self.unknown
    }
}
