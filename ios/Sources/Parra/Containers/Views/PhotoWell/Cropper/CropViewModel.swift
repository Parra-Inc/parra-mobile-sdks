//
//  CropViewModel.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/25.
//

import SwiftUI
import UIKit

class CropViewModel: ObservableObject {
    // MARK: - Lifecycle

    init(
        maskRadius: CGFloat,
        maxMagnificationScale: CGFloat,
        maskShape: MaskShape,
        rectAspectRatio: CGFloat
    ) {
        self.maskRadius = maskRadius
        self.maxMagnificationScale = maxMagnificationScale
        self.maskShape = maskShape
        self.rectAspectRatio = rectAspectRatio
    }

    // MARK: - Internal

    var imageSizeInView: CGSize = .zero // The size of the image as displayed in the view.
    @Published var maskSize: CGSize =
        .zero // The size of the mask used for cropping. This is updated based on the mask shape and available space.
    @Published var scale: CGFloat = 1.0 // The current scale factor of the image.
    @Published var lastScale: CGFloat = 1.0 // The previous scale factor of the image.
    @Published var offset: CGSize = .zero // The current offset of the image.
    @Published var lastOffset: CGSize = .zero // The previous offset of the image.
    @Published var angle: Angle =
        .init(degrees: 0) // The current rotation angle of the image.
    @Published var lastAngle: Angle =
        .init(degrees: 0) // The previous rotation angle of the image.

    func updateMaskDimensions(for imageSizeInView: CGSize) {
        self.imageSizeInView = imageSizeInView
        updateMaskSize(for: imageSizeInView)
    }

    func calculateDragGestureMax() -> CGPoint {
        let xLimit = max(0, ((imageSizeInView.width / 2) * scale) - (maskSize.width / 2))
        let yLimit = max(
            0,
            ((imageSizeInView.height / 2) * scale) - (maskSize.height / 2)
        )
        return CGPoint(x: xLimit, y: yLimit)
    }

    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let minScale = max(
            maskSize.width / imageSizeInView.width,
            maskSize.height / imageSizeInView.height
        )
        return (minScale, maxMagnificationScale)
    }

    func cropToRectangle(_ image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)

        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else
        {
            return nil
        }

        return UIImage(cgImage: result)
    }

    func cropToSquare(_ image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)

        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else
        {
            return nil
        }

        return UIImage(cgImage: result)
    }

    func rotate(_ image: UIImage, _ angle: Angle) -> UIImage? {
        guard let orientedImage = image.correctlyOriented,
              let cgImage = orientedImage.cgImage else
        {
            return nil
        }

        let ciImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter.straightenFilter(
            image: ciImage,
            radians: angle.radians
        ),
            let output = filter.outputImage else
        {
            return nil
        }

        let context = CIContext()
        guard let result = context.createCGImage(output, from: output.extent) else {
            return nil
        }

        return UIImage(cgImage: result)
    }

    // MARK: - Private

    private let maskRadius: CGFloat
    private let maxMagnificationScale: CGFloat // The maximum allowed scale factor for image magnification.
    private let maskShape: MaskShape // The shape of the mask used for cropping.
    private let rectAspectRatio: CGFloat // The aspect ratio for rectangular masks.

    private func updateMaskSize(for size: CGSize) {
        switch maskShape {
        case .circle, .square:
            let diameter = min(maskRadius * 2, min(size.width, size.height))
            maskSize = CGSize(width: diameter, height: diameter)
        case .rectangle:
            let maxWidth = min(size.width, maskRadius * 2)
            let maxHeight = min(size.height, maskRadius * 2)
            if maxWidth / maxHeight > rectAspectRatio {
                maskSize = CGSize(width: maxHeight * rectAspectRatio, height: maxHeight)
            } else {
                maskSize = CGSize(width: maxWidth, height: maxWidth / rectAspectRatio)
            }
        }
    }

    private func calculateCropRect(_ orientedImage: UIImage) -> CGRect {
        let factor = min(
            orientedImage.size.width / imageSizeInView.width,
            orientedImage.size.height / imageSizeInView.height
        )
        let centerInOriginalImage = CGPoint(
            x: orientedImage.size.width / 2,
            y: orientedImage.size.height / 2
        )

        let cropSizeInOriginalImage = CGSize(
            width: (maskSize.width * factor) / scale,
            height: (maskSize.height * factor) / scale
        )

        let offsetX = offset.width * factor / scale
        let offsetY = offset.height * factor / scale

        let cropRectX = (centerInOriginalImage.x - cropSizeInOriginalImage.width / 2) -
            offsetX
        let cropRectY = (centerInOriginalImage.y - cropSizeInOriginalImage.height / 2) -
            offsetY

        return CGRect(
            origin: CGPoint(x: cropRectX, y: cropRectY),
            size: cropSizeInOriginalImage
        )
    }
}

private extension UIImage {
    var correctlyOriented: UIImage? {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}

private extension CIFilter {
    static func straightenFilter(image: CIImage, radians: Double) -> CIFilter? {
        let angle: Double = radians != 0 ? -radians : 0
        guard let filter = CIFilter(name: "CIStraightenFilter") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(angle, forKey: kCIInputAngleKey)
        return filter
    }
}
