//
//  JSONEncoder.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

private let parraJsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    
    encoder.keyEncodingStrategy = .convertToSnakeCase
#if DEBUG
    encoder.outputFormatting = .prettyPrinted
#endif
    
    return encoder
}()

extension JSONEncoder {
    static var parraEncoder: JSONEncoder {
        return parraJsonEncoder
    }
}
