//
//  ParraContainerPreview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// To be used internally to provide Parra related context for an entire scene.
/// If you're building a component view, use ``ParraViewPreview`` instead.
@MainActor
struct ParraContainerPreview<Content>: View where Content: Container {
    // MARK: - Lifecycle

    init(
        content: @escaping (_ factory: ComponentFactory<Content.Factory>)
            -> Content,
        localFactory: Content.Factory? = nil,
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.options = [.theme(theme)]
        self.localFactory = ComponentFactory<Content.Factory>(
            local: localFactory,
            global: GlobalComponentAttributes(),
            theme: theme
        )
    }

    // MARK: - Internal

    var body: some View {
        // It is tempting to store the content observer for the container in env
        // here but this will only work for previews. At runtime, the app
        // wrapper won't have provided this object since it is specific to the
        // individual containers.
        ParraAppView(
            authProvider: .preview,
            options: options,
            appDelegateType: ParraAppDelegate.self,
            launchScreenConfig: .preview,
            sceneContent: {
                content(localFactory)
            }
        )
    }

    // MARK: - Private

    @ViewBuilder private var content: (_ factory: ComponentFactory<
        Content
            .Factory
    >) -> Content
    private let localFactory: ComponentFactory<Content.Factory>
    private let options: [ParraConfigurationOption]
}
