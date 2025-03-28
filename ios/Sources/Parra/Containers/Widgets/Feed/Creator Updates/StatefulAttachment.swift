//
//  StatefulAttachment.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import PhotosUI
import SwiftUI

enum Attachment: Hashable {
    case image(ParraImageAsset)
}

enum StatefulAttachment: Hashable {
    case processing(
        _ item: PhotosPickerItem,
        _ image: UIImage?
    )
    case uploaded(
        _ asset: ParraImageAsset,
        _ item: PhotosPickerItem,
        _ image: UIImage
    )
    case errored(
        _ message: String,
        _ item: PhotosPickerItem
    )

    // MARK: - Internal

    var asset: ParraImageAsset? {
        switch self {
        case .processing:
            return nil
        case .uploaded(let asset, _, _):
            return asset
        case .errored:
            return nil
        }
    }

    var item: PhotosPickerItem {
        switch self {
        case .errored(_, let erroredItem):
            return erroredItem
        case .processing(let processingItem, _):
            return processingItem
        case .uploaded(_, let uploadedItem, _):
            return uploadedItem
        }
    }
}
