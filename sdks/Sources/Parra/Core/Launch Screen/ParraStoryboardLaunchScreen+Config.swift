//
//  ParraStoryboardLaunchScreen+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraStoryboardLaunchScreen {
    struct Config: Equatable {
        // MARK: - Lifecycle

        public init(
            name: String = Config.default.name,
            bundle: Bundle = Config.default.bundle,
            viewControllerIdentifier: String = Config.default
                .viewControllerIdentifier
        ) {
            self.name = name
            self.bundle = bundle
            self.viewControllerIdentifier = viewControllerIdentifier
        }

        // MARK: - Public

        public static let `default` = Config(
            name: "LaunchScreen",
            bundle: .main,
            viewControllerIdentifier: "Main"
        )

        /// If the filename of your storyboard is LaunchScreen.storyboard, then
        /// its name is "LaunchScreen"
        public let name: String

        /// The bundle where the Storyboard with the supplied name is expected
        /// to be stored.
        public let bundle: Bundle
        public let viewControllerIdentifier: String

        public static func fromInfoDictionary(
            in bundle: Bundle
        ) -> Config? {
            guard let bundleInfo = bundle.infoDictionary else {
                return nil
            }

            // If the top level launch screen key isn't set, this isn't the type
            // of launch screen we should try to use. If it is and the fields
            // are empty, use it with nil values.
            guard var storyboardName =
                bundleInfo["UILaunchStoryboardName"] as? String else
            {
                return nil
            }

            let suffix = ".storyboard"
            if storyboardName.hasSuffix(suffix) {
                storyboardName = String(storyboardName.dropLast(suffix.count))
            }

            return Config(
                name: storyboardName,
                bundle: bundle
            )
        }
    }
}
