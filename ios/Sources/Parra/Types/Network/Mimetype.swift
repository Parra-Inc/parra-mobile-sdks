//
//  Mimetype.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

enum Mimetype {
    case applicationJson
    case applicationFormUrlEncoded
    case multipartFormData(boundary: String)
    case imagePng
    case plainText

    // MARK: - Internal

    var rawValue: String {
        switch self {
        case .applicationJson:
            return "application/json"
        case .applicationFormUrlEncoded:
            return "application/x-www-form-urlencoded"
        case .multipartFormData(let boundary):
            return "multipart/form-data; boundary=\(boundary)"
        case .imagePng:
            return "image/png"
        case .plainText:
            return "text/plain"
        }
    }
}
