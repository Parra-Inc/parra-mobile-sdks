//
//  URLRequest+headers.swift
//  Parra
//
//  Created by Mick MacCallum on 8/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

extension URLRequest {
    @MainActor
    mutating func setValue(for field: URLRequestHeaderField) {
        setValue(field.value, forHTTPHeaderField: field.name)
    }

    @MainActor
    mutating func setValue(
        for header: TrackingHeader,
        with headerFactory: HeaderFactory
    ) {
        setValue(
            headerFactory.currentValue(for: header),
            forHTTPHeaderField: headerFactory.prefixedName(for: header)
        )
    }
}
