//
//  URLRequestHeaderField.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum URLRequestHeaderField {
    case authorization(AuthorizationType)
    case accept(Mimetype)
    case contentType(Mimetype)

    var name: String {
        switch self {
        case .authorization:
            return "Authorization"
        case .accept:
            return "Accept"
        case .contentType:
            return "Content-Type"
        }
    }

    var value: String {
        switch self {
        case .authorization(let authorizationType):
            return authorizationType.value
        case .accept(let mimetype):
            return mimetype.rawValue
        case .contentType(let mimetype):
            return mimetype.rawValue
        }
    }
}
