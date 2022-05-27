//
//  JSONDecoder.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

private let parraJsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    
    // Apparently this is problematic when mixed with custom decoders
    //    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    return decoder
}()

extension JSONDecoder {
    static var parraDecoder: JSONDecoder {
        return parraJsonDecoder
    }
}
