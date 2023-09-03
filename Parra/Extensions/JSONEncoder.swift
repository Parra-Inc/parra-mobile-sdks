//
//  JSONEncoder.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation


extension JSONEncoder {
    static var parraEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

#if DEBUG
        encoder.outputFormatting = .prettyPrinted
#endif

        return encoder
    }()

    static var spaceOptimizedEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.withoutEscapingSlashes]

        return encoder
    }()

    static var parraPrettyConsoleEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

        // TODO: Make this a function that accepts options for data/etc encoding strategies.

        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dataEncodingStrategy = .custom({ _, encoder in
            var container = encoder.singleValueContainer()
            try container.encode("<data>")
        })
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "NaN"
        )
        encoder.outputFormatting = [
            .withoutEscapingSlashes, .sortedKeys, .prettyPrinted
        ]

        return encoder
    }()
}
