//
//  Parra+Constants.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

public extension Parra {
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

    static func appBundleName() -> String? {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }

    static func appIconFilePath() -> URL? {
        let bundle = Bundle.main

        guard let icons = bundle.object(
            forInfoDictionaryKey: "CFBundleIcons"
        ) as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any] else
        {
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
