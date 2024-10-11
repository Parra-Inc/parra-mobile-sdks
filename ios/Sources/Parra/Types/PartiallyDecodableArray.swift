//
//  PartiallyDecodableArray.swift
//
//
//  Created by Mick MacCallum on 9/10/24.
//

import Foundation

private struct Empty: Decodable {}

private extension UnkeyedDecodingContainer {
    public mutating func skip() throws {
        _ = try decode(Empty.self)
    }
}

public struct PartiallyDecodableArray<Element>: Codable, Equatable,
    Hashable where Element: Codable & Equatable & Hashable
{
    // MARK: - Lifecycle

    public init(_ elements: [Element]) {
        self.elements = elements
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Element] = []

        while !container.isAtEnd {
            do {
                let element = try container.decode(Element.self)

                elements.append(element)
            } catch {
                try? container.skip()

                ParraLogger.error("Failed to decode an element", error)
            }
        }

        self.elements = elements
    }

    // MARK: - Public

    public let elements: [Element]

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in elements {
            try container.encode(element)
        }
    }
}

// public protocol ParraEnum: Equatable, Hashable {}
//
// public struct ParraEnumUknownCaseWrapper<T>: Codable, Equatable, Hashable where T: ParraEnum & Codable {
//    public let value: T?
//
//    init(value: T?) {
//        self.value = value
//    }
//
//    public init(from decoder: any Decoder) throws {
//        let container = try decoder.singleValueContainer()
//
//        do {
//            value = try container.decode(T.self)
//        } catch {
//            let unhandledCase = try? container.decode(String.self)
//            let caseName = unhandledCase ?? "unknown-case"
//
//            ParraLogger.error("enum \(type(of: T.self)) failed to decode. Unknown case: \(caseName)", error)
//
//            throw error
//        }
//    }
//
//    public func encode(to encoder: any Encoder) throws {
//        var container = try encoder.singleValueContainer()
//
//        try container.encode(value)
//    }
// }
