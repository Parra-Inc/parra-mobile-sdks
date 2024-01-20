//
//  JSONDecoder.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

extension JSONDecoder {
    internal private(set) static var parraDecoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }()

    internal private(set) static var spaceOptimizedDecoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()
}
