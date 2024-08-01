//
//  MultipartFormField.swift
//  Parra
//
//  Created by Mick MacCallum on 4/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

struct MultipartFormField {
    // MARK: - Lifecycle

    init(
        name: String,
        image: UIImage
    ) throws {
        guard let value = image.pngData() else {
            throw ParraError.message("Failed to convert image to PNG data")
        }

        self.name = name
        self.fileName = "\(name).png"
        self.value = value
        self.contentType = .imagePng
    }

    init(
        name: String,
        fileName: String? = nil,
        value: Data,
        contentType: Mimetype
    ) {
        self.name = name
        self.fileName = fileName ?? name
        self.value = value
        self.contentType = contentType
    }

    // MARK: - Internal

    let name: String
    let fileName: String
    let value: Data
    let contentType: Mimetype

    func fieldData(
        with boundary: String
    ) -> Data {
        var data = Data()

        data.append(
            "\r\n--\(boundary)\r\n".data(using: .utf8)!
        )

        data.append(
            "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
                .data(using: .utf8)!
        )

        data.append(
            "Content-Type: \(contentType.rawValue)\r\n\r\n"
                .data(using: .utf8)!
        )

        data.append(value)

        return data
    }
}
