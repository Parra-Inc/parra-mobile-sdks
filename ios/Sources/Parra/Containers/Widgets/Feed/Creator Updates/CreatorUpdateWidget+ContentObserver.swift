//
//  CreatorUpdateWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Combine
import PhotosUI
import SwiftUI

private let logger = Logger()

// 1. Store current WIP state for creator update.
// 2. Allow save as draft, discard, publish (with scheduling)
// 3. Allow uploading assets

// MARK: - FeedWidget.ContentObserver

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

// MARK: - CreatorUpdateWidget.ContentObserver

extension CreatorUpdateWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.config = initialParams.config
            self.api = initialParams.api
            self.templates = initialParams.templates
            self.content = Content()
            self.isLoading = false
        }

        // MARK: - Internal

        private(set) var content: Content

        let api: API

        var templates: [CreatorUpdateTemplate]

        var creatorUpdate: NewCreatorUpdate?

        var isLoading: Bool

        var submissionHandler: ((CreatorUpdate) -> Void)?

        func createPost(
            scheduleAt: Date? = nil
        ) async throws {
            logger.info("Creating new post", [
                "scheduledAt": scheduleAt?.formatted() ?? "now"
            ])

            guard let creatorUpdate else {
                throw ParraError.message(
                    "Tried to create post with no creator update is set."
                )
            }

            isLoading = true

            defer {
                isLoading = false
            }

            do {
                let response = try await api.postCreateCreatorUpdate(
                    // publish and scheduleAt are mutually exclusive.
                    publish: scheduleAt == nil,
                    scheduleAt: scheduleAt,
                    templateId: creatorUpdate.selectedTemplate.id,
                    topic: creatorUpdate.topic,
                    title: creatorUpdate.title.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    body: creatorUpdate.body.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    attachmentIds: .init(
                        creatorUpdate.attachments.compactMap { attachment in
                            return attachment.asset?.id
                        }
                    ),
                    postVisibility: creatorUpdate.visibility.postVisibility,
                    attachmentVisibility: creatorUpdate.visibility.attachmentVisibility
                )

                logger.info("Successfully created post!")

                submissionHandler?(response)
            } catch {
                logger.error("Failed to create post", error)

                throw error
            }
        }

        func attachImage(
            from item: PhotosPickerItem,
            onStart: () -> Void
        ) async {
            logger.info(
                "Adding attachment for creator update",
                [
                    "itemId": item.itemIdentifier ?? "<null>"
                ]
            )

            // Check if an attachment with this picker item already exists
            if let matchIndex = findAttachmentIndex(for: item),
               let match = creatorUpdate?.attachments[matchIndex]
            {
                switch match {
                case .processing, .uploaded:
                    logger.warn("Attachment already existed. Skipping", [
                        "itemId": item.itemIdentifier ?? "<null>"
                    ])

                    return
                case .errored:
                    logger.debug("Attachment had previously errored. Allowing retry.")

                    creatorUpdate?.attachments.remove(at: matchIndex)
                }
            }

            // Add it to the list right away to show the processing state.
            updateState(
                for: item,
                to: .processing(item, nil)
            )

            onStart()

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

                let asset = try await api.uploadAsset(
                    with: pngData,
                    group: "creator-update-attachment"
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

        private var paginatorSink: AnyCancellable? = nil

        private let config: ParraCreatorUpdateConfiguration

        private func findAttachmentIndex(
            for pickerItem: PhotosPickerItem
        ) -> Int? {
            guard let creatorUpdate else {
                return nil
            }

            guard let itemIdentifier = pickerItem.itemIdentifier else {
                return nil
            }

            return creatorUpdate.attachments.firstIndex { attachment in
                switch attachment {
                case .errored(_, let erroredItem):
                    return itemIdentifier == erroredItem.itemIdentifier
                case .processing(let processingItem, _):
                    return itemIdentifier == processingItem.itemIdentifier
                case .uploaded(_, let uploadedItem, _):
                    return itemIdentifier == uploadedItem.itemIdentifier
                }
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

            if let matchIndex = findAttachmentIndex(for: pickerItem) {
                creatorUpdate?.attachments[matchIndex] = newState
            } else {
                creatorUpdate?.attachments.append(newState)
            }
        }
    }
}
