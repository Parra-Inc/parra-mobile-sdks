//
//  ParraProfilePhotoWell.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

public struct ParraProfilePhotoWell: View {
    // MARK: - Lifecycle

    public init(
        size: CGSize = CGSize(width: 50, height: 50)
    ) {
        self.size = size
    }

    // MARK: - Public

    public var body: some View {
        switch parraAuthState {
        case .authenticated(let user), .anonymous(let user):
            PhotoWell(
                stub: user.info.avatar,
                size: size
            ) { newAvatar in
                await onAvatarSelected(newAvatar)
            }
            .id(user.info.avatar?.id)
        case .undetermined, .guest, .error:
            PhotoWell(
                stub: nil,
                size: size,
                onSelectionChanged: nil
            )
        }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme

    // MARK: - Private

    private let size: CGSize

    private func onAvatarSelected(
        _ image: UIImage?
    ) async {
        do {
            if let image {
                let resized = image.resized()
                let asset = try await parra.parraInternal.api.uploadAvatar(
                    image: resized
                )

                await parra.parraInternal.api.cacheAsset(asset)
            } else {
                try await parra.parraInternal.api.deleteAvatar()
            }

            try await parra.parraInternal.authService.refreshUserInfo()
        } catch {
            logger.error("Error uploading avatar", error)
        }
    }
}
