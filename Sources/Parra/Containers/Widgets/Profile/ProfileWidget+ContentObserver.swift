//
//  ProfileWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

// MARK: - ProfileWidget.ContentObserver

extension ProfileWidget {
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(initialParams: InitialParams) {
            self.content = Content()
            self.api = initialParams.api
        }

        // MARK: - Internal

        var content: Content

        func onAvatarSelectionChange(image: UIImage) async {
            do {
                let resized = image.resized()
                let asset = try await api.uploadAvatar(
                    image: resized
                )

                await api.cacheAsset(asset)
            } catch {
                logger.error("Error uploading avatar", error)
            }
        }

        // MARK: - Private

        private let api: API
    }
}

// MARK: - ProfileWidget.ContentObserver.Content

extension ProfileWidget.ContentObserver {
    struct Content: ContainerContent {}
}

// MARK: - ProfileWidget.ContentObserver.InitialParams

extension ProfileWidget.ContentObserver {
    struct InitialParams {
        let api: API
    }
}
