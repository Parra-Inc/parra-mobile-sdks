//
//  ParraSanitizedDictionary.swift
//  Parra
//
//  Created by Mick MacCallum on 9/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraSanitizedDictionary: ExpressibleByDictionaryLiteral {
    // MARK: - Lifecycle

    init(dictionaryLiteral elements: (Key, Value)...) {
        self.dictionary = Dictionary(
            uniqueKeysWithValues: elements.map { key, value in
                switch value {
                case let url as URL:
                    return (key, ParraSanitizedDictionary.sanitize(url: url))
                default:
                    return (key, value)
                }
            }
        )
    }

    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    // MARK: - Internal

    typealias Key = String
    typealias Value = Any

    let dictionary: [Key: Value]

    // MARK: - Private

    private static func sanitize(url: URL) -> URL {
        // TODO: This method and others like it...
        // Maybe values of query params become ****
        return url
    }
}

// MARK: Encodable

extension ParraSanitizedDictionary: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(AnyCodable(dictionary))
    }
}
