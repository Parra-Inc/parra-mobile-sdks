//
//  StatefulAttachment.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import PhotosUI
import SwiftUI

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
}
