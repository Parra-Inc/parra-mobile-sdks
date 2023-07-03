//
//  URLRequest.swift
//  Parra
//
//  Created by Mick MacCallum on 8/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal extension URLRequest {
    mutating func setValue(for field: URLRequestHeaderField) {
        setValue(field.value, forHTTPHeaderField: field.name)
    }

    mutating func setValue(_ value: String?, forHTTPHeaderField field: ParraHeader) {
        setValue(value, forHTTPHeaderField: field.prefixedName)
    }

    mutating func setValue(for parraHeader: ParraHeader) {
        setValue(parraHeader.currentValue, forHTTPHeaderField: parraHeader.prefixedName)
    }
}
