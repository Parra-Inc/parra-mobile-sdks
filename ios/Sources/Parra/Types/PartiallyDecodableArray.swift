//
//  PartiallyDecodableArray.swift
//
//
//  Created by Mick MacCallum on 9/10/24.
//

import Foundation

private struct Empty: Decodable {}

private extension UnkeyedDecodingContainer {
    mutating func skip() throws {
        _ = try decode(Empty.self)
    }
}

public struct PartiallyDecodableArray<Element>: Codable, Equatable,
    Hashable, Sendable where Element: Codable & Equatable & Hashable & Sendable
{
    // MARK: - Lifecycle

    public init(_ elements: [Element]) {
        self.elements = elements
    }

    public init?(_ elements: [Element]?) {
        guard let elements else {
            return nil
        }

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

                #if DEBUG
                if ParraInternal.isBundleIdDevApp() {
                    fatalError(
                        "Failed to decode array element of type: \(Element.self) - \(error.localizedDescription)"
                    )
                }
                #endif

                ParraLogger.error(
                    "Failed to decode an element of type: \(Element.self)",
                    error
                )
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
