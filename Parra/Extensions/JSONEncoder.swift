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
}
