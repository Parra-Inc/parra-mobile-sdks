//
//  ParraSanitizedDictionary.swift
//  Parra
//
//  Created by Mick MacCallum on 9/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSanitizedDictionary: ExpressibleByDictionaryLiteral {
    typealias Key = String
    typealias Value = Any

    internal let dictionary: [Key : Value]

    internal init(dictionaryLiteral elements: (Key, Value)...) {
        dictionary = Dictionary(
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

    internal init(dictionary: [String : Any]) {
        self.dictionary = dictionary
    }

    private static func sanitize(url: URL) -> URL {
        // TODO: This method and others like it...
        return url
    }
}

extension ParraSanitizedDictionary: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(AnyCodable(dictionary))
    }
}
