//
//  Parra+Constants.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

public extension Parra {
    internal enum Demo {
        /// The Parra sample app's workspace ID. You should not use this.
        /// Instead, grab your workspace ID from
        /// https://parra.io/dashboard/settings
        static let workspaceId = "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4"

        /// The Parra sample app's application ID. You should not use this.
        /// Instead, grab your application ID from
        /// https://parra.io/dashboard/applications
        static let applicationId = "edec3a6c-a375-4a9d-bce8-eb00860ef228"

        /// The Parra sample app's API key. You should not use this. It is best
        /// practice to use the
        /// ``ParraAuthenticationMethod/custom(_:)`` or
        /// ``ParraAuthenticationMethod/parraAuth``
        /// authentication provider methods, which do not expose your API keys
        /// to end users that have access to your application bundle. If you
        /// still need to use API key based authentication, you can generate
        /// your own key at https://parra.io/dashboard/developer/api-keys
        static let apiKeyId = "27300ac2-6ea9-4fd0-b337-9efa4d756d90"

        /// A user ID to use for demo purposes. This is just a UUID generated
        /// and attached to this device.
        static let demoUserId = ParraDeviceInfoManager.current.id
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

    static func appBundleName(
        bundle: Bundle = Bundle.main
    ) -> String? {
        return bundle.infoDictionary?["CFBundleName"] as? String
    }

    static func appIconFilePath(
        bundle: Bundle = Bundle.main
    ) -> URL? {
        guard let icons = bundle.object(
            forInfoDictionaryKey: "CFBundleIcons"
        ) as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any] else {
            return nil
        }

        var allIconNames = [String]()

        if let iconFileName = primaryIcon["CFBundleIconName"] as? String {
            allIconNames.append(iconFileName)
        }

        if let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let iconFileName = iconFiles.last
        {
            allIconNames.append(iconFileName)
        }

        let resourceUrls = bundle.urls(
            forResourcesWithExtension: nil,
            subdirectory: nil
        ) ?? []

        for url in resourceUrls {
            let fileName = url.deletingPathExtension().lastPathComponent

            let components = fileName.split(separator: "@")

            if let first = components.first {
                for iconName in allIconNames {
                    if iconName == String(first) {
                        return url
                    }
                }
            }
        }

        return nil
    }
}
