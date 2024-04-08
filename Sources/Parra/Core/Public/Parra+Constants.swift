//
//  Parra+Constants.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

public extension Parra {
    enum Demo {
        /// The Parra sample app's workspace ID. You should not use this. Instead,
        /// grab your workspace ID from https://parra.io/dashboard/settings
        public static let workspaceId = "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4"

        /// The Parra sample app's application ID. You should not use this.
        /// Instead, grab your application ID from
        /// https://parra.io/dashboard/applications
        public static let applicationId = "edec3a6c-a375-4a9d-bce8-eb00860ef228"

        /// The Parra sample app's API key. You should not use this. It is best
        /// practice to use the
        /// ``ParraAuthenticationProviderType/default(workspaceId:applicationId:authProvider:)``
        /// authentication provider method, which does not expose your API keys
        /// to end users that have access to your application bundle. If you
        /// still need to use API key based authentication, you can generate
        /// your own key at https://parra.io/dashboard/developer/api-keys
        public static let apiKeyId = "27300ac2-6ea9-4fd0-b337-9efa4d756d90"

        /// A user ID to use for demo purposes. This is just the
        /// identifierForVendor so that it is mostly stable but falls back on a
        /// UUID if the vendor ID can not be obtained.
        public static let demoUserId = (
            UIDevice.current.identifierForVendor ?? .init()
        ).uuidString
    }

    enum Constants {
        // MARK: - Public facing constants

        /// A key that cooresponds to a unique sync token provided with sync
        /// begin/ending notifications.
        public static let syncTokenKey = "syncToken"

        public static let brandColor = UIColor(
            red: 232.0 / 255.0,
            green: 68.0 / 255.0,
            blue: 71.0 / 255.0,
            alpha: 1.0
        )

        public static let parraWebRoot = URL(string: "https://parra.io/")!
    }
}
