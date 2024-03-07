//
//  ParraViewPreview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// To be used internally to provide Parra related context for individual views.
/// If you're building a top level scene, use ``ParraContainerPreview`` instead.
@MainActor
struct ParraViewPreview<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        content: @escaping () -> Content,
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.options = [.theme(theme)]
        self.factory = ComponentFactory(
            global: GlobalComponentAttributes(),
            theme: theme
        )
    }

    // MARK: - Internal

    var body: some View {
        ParraAppView(
            authProvider: .preview,
            options: options,
            appDelegateType: ParraAppDelegate.self,
            launchScreenConfig: .preview,
            sceneContent: { _ in
                content()
            }
        )
        .environmentObject(factory)
    }

    // MARK: - Private

    @ViewBuilder private var content: () -> Content

    private let factory: ComponentFactory
    private let options: [ParraConfigurationOption]
}
