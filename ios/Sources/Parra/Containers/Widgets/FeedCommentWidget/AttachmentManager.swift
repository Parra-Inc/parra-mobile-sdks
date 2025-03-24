//
//  AttachmentManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/25.
//

import PhotosUI
import SwiftUI

private let logger = Logger()

@Observable
@MainActor
class AttachmentManager {
    // MARK: - Lifecycle

    required init(
        group: String
    ) {
        self.group = group
    }

    // MARK: - Internal

    let group: String

    var isLoading: Bool = false

    var showingPhotoPicker = false

    var attachments: [StatefulAttachment] = []

    var selectedPhotos: [PhotosPickerItem] = [] {
        didSet {
            processSelectedPhotosChange()
        }
    }

    func clear() {
        attachments = []
        selectedPhotos = []
    }

    func removeAttachment(_ attachment: StatefulAttachment) {
        if let attachmentIndex = findAttachmentIndex(for: attachment.item) {
            attachments.remove(at: attachmentIndex)
        }

        if let selectedPhotoIndex = selectedPhotos.firstIndex(where: { item in
            return item.itemIdentifier == attachment.item.itemIdentifier
        }) {
            selectedPhotos.remove(at: selectedPhotoIndex)
        }
    }

    func attachImage(
        from item: PhotosPickerItem,
        onStart: (() -> Void)? = nil
    ) async {
        logger.info(
            "Adding attachment for creator update",
            [
                "itemId": item.itemIdentifier ?? "<null>"
            ]
        )

        // Check if an attachment with this picker item already exists
        if let matchIndex = findAttachmentIndex(for: item) {
            let match = attachments[matchIndex]

            switch match {
            case .processing, .uploaded:
                logger.warn("Attachment already existed. Skipping", [
                    "itemId": item.itemIdentifier ?? "<null>"
                ])

                return
            case .errored:
                logger.debug("Attachment had previously errored. Allowing retry.")

                attachments.remove(at: matchIndex)
            }
        }

        // Add it to the list right away to show the processing state.
        updateState(
            for: item,
            to: .processing(item, nil)
        )

        onStart?()

        do {
            let data = try await item.loadTransferable(
                type: Data.self
            )

            guard let data, let image = UIImage(data: data) else {
                throw ParraError.message(
                    "Failed to load image data from selected photo"
                )
            }

            // Server won't allow above 50MB
            let resizedImage = image.resized(
                maxSize: 50,
                unit: .megabytes,
                removeAlpha: true
            )

            let thumb = resizedImage.resized(
                maxSize: CGSize(
                    width: 500,
                    height: 500
                ),
                removeAlpha: true
            )

            guard let ciImage = CIImage(
                image: resizedImage,
                options: [
                    .applyOrientationProperty: true,
                    .properties: [
                        kCGImagePropertyOrientation: CGImagePropertyOrientation(
                            resizedImage.imageOrientation
                        ).rawValue
                    ]
                ]
            ) else {
                throw ParraError.message(
                    "Failed to perform necessary image conversion"
                )
            }

            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                throw ParraError.message("Failed to use sRGB colorspace")
            }

            let context = CIContext()
            guard let pngData = context.pngRepresentation(
                of: ciImage,
                format: .RGBA8,
                colorSpace: colorSpace
            ) else {
                throw ParraError.message("Failed to convert image to PNG")
            }

            updateState(
                for: item,
                to: .processing(item, thumb)
            )

            let asset = try await Parra.default.parraInternal.api.uploadAsset(
                with: pngData,
                group: group
            )

            updateState(
                for: item,
                to: .uploaded(asset, item, thumb)
            )
        } catch {
            logger.error(
                "Error uploading attachment for creator update", error
            )

            updateState(
                for: item,
                to: .errored(error.localizedDescription, item)
            )
        }
    }

    // MARK: - Private

    private func processSelectedPhotosChange() {
        attachments = attachments.compactMap { attachment in
            // Remove all attachments that are no longer in the selection.

            let contains = selectedPhotos.contains { item in
                return item.itemIdentifier == attachment.item.itemIdentifier
            }

            if contains {
                return attachment
            }

            return nil
        }

        // TODO: Merge these instead of inserting all at the end?
        for selectedPhoto in selectedPhotos {
            let contains = attachments.contains { attachment in
                return attachment.item.itemIdentifier == selectedPhoto.itemIdentifier
            }

            if !contains {
                Task {
                    await attachImage(from: selectedPhoto)
                }
            }
        }
    }

    private func findAttachmentIndex(
        for pickerItem: PhotosPickerItem
    ) -> Int? {
        guard let itemId = pickerItem.itemIdentifier else {
            return nil
        }

        return findAttachmentIndex(for: itemId)
    }

    private func findAttachmentIndex(
        for itemId: String
    ) -> Int? {
        return attachments.firstIndex { attachment in
            return attachment.item.itemIdentifier == itemId
        }
    }

    private func updateState(
        for pickerItem: PhotosPickerItem,
        to newState: StatefulAttachment
    ) {
        switch newState {
        case .processing(let item, let image):
            logger.debug("Attachment is processing", [
                "itemId": item.itemIdentifier ?? "<null>",
                "hasImage": String(image != nil)
            ])
        case .uploaded(let asset, let item, _):
            logger.debug("Attachment is uploaded", [
                "itemId": item.itemIdentifier ?? "<null>",
                "assetId": asset.id
            ])
        case .errored(let message, let item):
            logger.error(
                "Failed to upload asset",
                [
                    "itemId": item.itemIdentifier ?? "<null>",
                    "message": message
                ]
            )
        }

        Task { @MainActor in
            if let matchIndex = findAttachmentIndex(for: pickerItem) {
                attachments[matchIndex] = newState
            } else {
                attachments.append(newState)
            }
        }
    }
}
