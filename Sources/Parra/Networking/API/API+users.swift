//
//  API+users.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

extension API {
    func uploadAvatar(
        image: UIImage
    ) async throws -> ImageAssetStub {
        let imageField = try MultipartFormField(
            name: "image", // server side requirement
            image: image
        )

        return try await hitUploadEndpoint(
            .postUpdateAvatar,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            formFields: [imageField]
        )
    }
}
