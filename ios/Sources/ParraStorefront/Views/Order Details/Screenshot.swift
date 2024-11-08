//
//  Screenshot.swift
//  Parra
//
//  Created by Mick MacCallum on 11/8/24.
//

import SwiftUI

struct Screenshot: Transferable {
    // MARK: - Lifecycle

    init(image: UIImage, fileName: String) {
        self.image = image
        self.fileName = fileName
    }

    // MARK: - Internal

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { value in
            return value.image.pngData() ?? Data()
        }
        .suggestedFileName { screenshot in
            return screenshot.fileName
        }
    }

    let image: UIImage
    let fileName: String
}
