//
//  UIImage+resize.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AVFoundation
import UIKit

public extension UIImage {
    /// Resize image while keeping the aspect ratio. Original image is not modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resized(
        maxSize: CGSize = CGSize(width: 1_024, height: 1_024)
    ) -> UIImage {
        let availableRect = AVMakeRect(
            aspectRatio: size,
            insideRect: .init(origin: .zero, size: maxSize)
        )

        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: targetSize,
            format: format
        )

        // Resize the image
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized
    }
}
