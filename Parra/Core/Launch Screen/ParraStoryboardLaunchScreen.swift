//
//  ParraStoryboardLaunchScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraStoryboardLaunchScreen: UIViewControllerRepresentable {
    // MARK: - Lifecycle

    public init(
        config: Config
    ) {
        self.config = config
    }

    // MARK: - Public

    public func makeUIViewController(
        context: Context
    ) -> some UIViewController {
        let storyboard = UIStoryboard(
            name: config.name,
            bundle: config.bundle
        )

        return storyboard.instantiateViewController(
            identifier: config.viewControllerIdentifier
        )
    }

    public func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {}

    // MARK: - Private

    private let config: Config
}
