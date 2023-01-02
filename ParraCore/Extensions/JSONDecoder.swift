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
    
    return decoder
}()

extension JSONDecoder {
    static var parraDecoder: JSONDecoder {
        return parraJsonDecoder
    }
}
