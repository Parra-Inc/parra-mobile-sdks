//
//  ParraPreviewApp.swift
//  Parra
//
//  Created by Mick MacCallum on 2/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public struct ParraPreviewApp<Content, DelegateType>: View
    where Content: View, DelegateType: ParraAppDelegate
{
    // MARK: - Lifecycle

    public init(
        options: [ParraConfigurationOption] = [],
        previewContent: @MainActor @escaping () -> Content
    ) {
        self.options = options
        self.previewContent = previewContent
    }

    // MARK: - Public

    public var body: some View {
        ParraAppView(
            authProvider: .preview,
            options: options,
            appDelegateType: ParraAppDelegate.self,
            launchScreenConfig: .preview,
            sceneContent: previewContent
        )
    }

    // MARK: - Private

    private let options: [ParraConfigurationOption]
    private let previewContent: () -> Content
}
