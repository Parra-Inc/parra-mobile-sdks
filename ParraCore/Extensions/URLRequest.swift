//
//  URLRequest.swift
//  ParraCore
//
//  Created by Mick MacCallum on 8/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal enum URLRequestHeaderField: CustomStringConvertible {
    case authorization
    case accept
    case contentType

    var description: String {
        switch self {
        case .authorization:
            return "Authorization"
        case .accept:
            return "Accept"
        case .contentType:
            return "Content-Type"
        }
    }
}

internal extension URLRequest {
    mutating func setValue(_ value: String?, forHTTPHeaderField field: URLRequestHeaderField) {
        setValue(value, forHTTPHeaderField: field.description)
    }

    mutating func setValue(_ value: String?, forHTTPHeaderField field: ParraHeader) {
        setValue(value, forHTTPHeaderField: field.name)
    }

    mutating func setValue(for parraHeader: ParraHeader) {
        setValue(parraHeader.currentValue, forHTTPHeaderField: parraHeader.name)
    }
}
