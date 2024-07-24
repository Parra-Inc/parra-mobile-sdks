//
//  JSONDecoder.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

extension JSONDecoder {
    private(set) static var parraDecoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(dateDecoder)

        return decoder
    }()

    private(set) static var parraWebauthDecoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom(dateDecoder)

        return decoder
    }()

    private(set) static var spaceOptimizedDecoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(dateDecoder)

        return decoder
    }()

    private static func dateDecoder(
        _ decoder: Decoder
    ) throws -> Date {
        // iso8601 date decoding strategy fails due to default configuration
        // omitting support for fractional seconds.
        // See: https://stackoverflow.com/a/46538423/716216

        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        if let date = Date.fromIso8601String(dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Date string \"\(dateString)\" couldn't be formatted by ISO8601DateFormatter."
        )
    }
}
