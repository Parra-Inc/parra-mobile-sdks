//
//  UIImage+resize.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AVFoundation
import CoreGraphics
import CoreImage
import UIKit

private let logger = Logger()

extension Measurement where UnitType == UnitInformationStorage {
    var bytes: Measurement<UnitInformationStorage> {
        return converted(to: .bytes)
    }

    var byteCount: Int {
        return Int(converted(to: .bytes).value)
    }
}

extension UIImage {
    var hasAlpha: Bool {
        guard let cgImage else {
            // For CIImage-based UIImages, we need a different approach

            if let ciImage {
                // Check if the CIImage has an alpha channel by looking at its properties
                // This is an approximation since CIImage doesn't directly expose alpha info
                return ciImage
                    .properties[kCGImagePropertyHasAlpha as String] as? Bool ?? false
            }

            return false
        }

        // Check if the bitmap info indicates an alpha channel
        let alphaInfo = cgImage.alphaInfo

        return alphaInfo != .none && alphaInfo != .noneSkipLast && alphaInfo !=
            .noneSkipFirst
    }
}

public extension UIImage {
    func resized(
        maxSize value: CGFloat,
        unit: UnitInformationStorage = .bytes,
        removeAlpha: Bool = false
    ) -> UIImage {
        let measurement = Measurement(value: Double(value), unit: unit)
        let bytesValue = measurement.converted(to: .bytes)

        let maxBytes = bytesValue.value
        let hasAlpha = hasAlpha

        // Calculate bits per pixel based on alpha channel
        let bitsPerPixel = removeAlpha ? 24.0 : 32.0 // RGB vs RGBA
        let currentBitsPerPixel = hasAlpha ? 24.0 : 32.0 // RGB vs RGBA
        let bytesPerPixel = bitsPerPixel / 8.0
        let currentBytesPerPixel = currentBitsPerPixel / 8.0

        // Calculate current estimated size in bytes
        let currentPixels = Double(size.width * size.height)
        let currentEstimatedBytes = currentPixels * currentBytesPerPixel

        // Check if current image already meets the requirements
        if currentEstimatedBytes <= maxBytes {
            // If we need to remove alpha but image already meets size requirements,
            // only perform the alpha removal operation
            if removeAlpha && hasAlpha {
                // Create copy without alpha channel
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                format.opaque = true

                let renderer = UIGraphicsImageRenderer(size: size, format: format)
                return renderer.image { _ in
                    draw(in: CGRect(origin: .zero, size: size))
                }
            }

            // Image meets size requirements and no alpha changes needed
            return self
        }

        // Calculate scale factor to fit within byte limit
        let scaleFactor = sqrt(maxBytes / currentEstimatedBytes)

        // Calculate target dimensions
        let targetWidth = size.width * CGFloat(scaleFactor)
        let targetHeight = size.height * CGFloat(scaleFactor)
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        let targetBytes = targetWidth * targetHeight * bytesPerPixel

        // Set up the renderer
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = removeAlpha

        // Create the resized image
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }

        logger.debug("Finished resizing image", [
            "requestedSize": "\(maxBytes.rounded()) bytes",
            "inputSize": "\(currentEstimatedBytes.rounded()) bytes",
            "outputSize": "\(targetBytes.rounded()) bytes"
        ])

        return resized
    }

    /// Resize image while keeping the aspect ratio. Original image is not
    /// modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resized(
        maxSize: CGSize = CGSize(width: 1_024, height: 1_024),
        removeAlpha: Bool = false
    ) -> UIImage {
        let availableRect = AVMakeRect(
            aspectRatio: size,
            insideRect: .init(origin: .zero, size: maxSize)
        )

        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        // Set opacity based on the removeAlpha parameter
        if removeAlpha {
            format.opaque = true // This removes the alpha channel
        } else {
            format.opaque = false // Preserves the alpha channel (default)
        }

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
