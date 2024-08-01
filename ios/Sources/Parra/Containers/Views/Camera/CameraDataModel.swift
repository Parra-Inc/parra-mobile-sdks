//
//  CameraDataModel.swift
//  Parra
//
//  Created by Mick MacCallum on 4/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AVFoundation
import SwiftUI

final class CameraDataModel: ObservableObject {
    // MARK: - Lifecycle

    init() {
        Task {
            await handleCameraPreviews()
        }
    }

    // MARK: - Internal

    let camera = Camera()

    @Published var viewfinderImage: Image?

    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map(\.image)

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
}

private extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else {
            return nil
        }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

private let logger = Logger()
