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
        content: @escaping (_ factory: ComponentFactory) -> Content,
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.configuration = .init(themeOptions: theme)
        self.factory = ComponentFactory(
            global: GlobalComponentAttributes(),
            theme: theme
        )
    }

    // MARK: - Internal

    var body: some View {
        ParraAppView(
            target: .preview,
            configuration: configuration,
            appDelegateType: ParraPreviewAppDelegate.self,
            sceneContent: { _ in
                content(factory)
            }
        )
        .environmentObject(factory)
    }

    // MARK: - Private

    @ViewBuilder private var content: (_ factory: ComponentFactory) -> Content

    private let factory: ComponentFactory
    private let configuration: ParraConfiguration
}
