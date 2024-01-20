//
//  JSONEncoder.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation


extension JSONEncoder {
    internal private(set) static var parraEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

#if DEBUG
        encoder.outputFormatting = .prettyPrinted
#endif

        return encoder
    }()

    // ! Important: can never use pretty printing. It is required by consumers
    // of this encoder that JSON all be on the same line.
    internal private(set) static var spaceOptimizedEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

#if DEBUG
        // When debugging we may be looking at these lines in an events file manually
        // and if they're sorted by key, each line will have its data in the same order.
        encoder.outputFormatting = [.withoutEscapingSlashes, .sortedKeys]
#else
        encoder.outputFormatting = [.withoutEscapingSlashes]
#endif

        return encoder
    }()

    internal private(set) static var parraPrettyConsoleEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

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
