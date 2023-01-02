//
//  JSONDecoder.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

private let parraJsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601

    return decoder
}()

extension JSONDecoder {
    static var parraDecoder: JSONDecoder {
        return parraJsonDecoder
    }
}
