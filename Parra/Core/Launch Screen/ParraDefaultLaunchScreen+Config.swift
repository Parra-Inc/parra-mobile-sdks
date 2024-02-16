//
//  ParraDefaultLaunchScreen+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraDefaultLaunchScreen {
    struct Config {
        // MARK: - Lifecycle

        public init(
            colorName: String? = nil,
            imageName: String? = nil,
            imageRespectsSafeAreaInsets: Bool? = nil,
            navigationBar: BarConfig? = nil,
            tabBar: BarConfig? = nil,
            toolBar: BarConfig? = nil,
            bundle: Bundle = .main
        ) {
            self.colorName = colorName
            self.imageName = imageName
            self.imageRespectsSafeAreaInsets = imageRespectsSafeAreaInsets
            self.navigationBar = navigationBar
            self.tabBar = tabBar
            self.toolBar = toolBar
            self.bundle = bundle
        }

        // MARK: - Public

        public struct BarConfig {
            // MARK: - Lifecycle

            public init(replacementImage: String?) {
                self.replacementImage = replacementImage
            }

            init?(from value: Any?) {
                guard let value else {
                    return nil
                }

                if let config = value as? [String: Any] {
                    self.replacementImage = config["UIImageName"] as? String
                } else {
                    // The key was set with no config, so use defaults.
                    self.replacementImage = nil
                }
            }

            // MARK: - Public

            public let replacementImage: String?
        }

        /// The name of the color that you'd like displayed as the background
        /// color. This is the name of a color in your assets catalog.
        public let colorName: String?
        public let imageName: String?
        public let imageRespectsSafeAreaInsets: Bool?
        public let navigationBar: BarConfig?
        public let tabBar: BarConfig?
        public let toolBar: BarConfig?

        /// The bundle where the Storyboard with the supplied name is expected
        /// to be stored.
        public let bundle: Bundle

        public static func fromInfoDictionary(
            in bundle: Bundle
        ) -> Config? {
            guard let bundleInfo = bundle.infoDictionary else {
                return nil
            }

            // If the top level launch screen key isn't set, this isn't the type
            // of launch screen we should try to use. If it is and the fields
            // are empty, use it with nil values.
            guard let launchInfo =
                bundleInfo["UILaunchScreen"] as? [String: Any] else
            {
                return nil
            }

            return Config(
                colorName: launchInfo["UIColorName"] as? String,
                imageName: launchInfo["UIImageName"] as? String,
                imageRespectsSafeAreaInsets: launchInfo[
                    "UIImageRespectsSafeAreaInsets"
                ] as? Bool,
                navigationBar: Config
                    .BarConfig(from: launchInfo["UINavigationBar"]),
                tabBar: Config.BarConfig(from: launchInfo["UITabBar"]),
                toolBar: Config.BarConfig(from: launchInfo["UIToolbar"]),
                bundle: bundle
            )
        }

        // MARK: - Internal

        func merging(overrides: Config?) -> Config {
            return Config(
                colorName: overrides?.colorName ?? colorName,
                imageName: overrides?.imageName ?? imageName,
                imageRespectsSafeAreaInsets: overrides?
                    .imageRespectsSafeAreaInsets ?? imageRespectsSafeAreaInsets,
                navigationBar: overrides?.navigationBar ?? navigationBar,
                tabBar: overrides?.tabBar ?? tabBar,
                toolBar: overrides?.toolBar ?? toolBar,
                bundle: overrides?.bundle ?? bundle
            )
        }
    }
}
