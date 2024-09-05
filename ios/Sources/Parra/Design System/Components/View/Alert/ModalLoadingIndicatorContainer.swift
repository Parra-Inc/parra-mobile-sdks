//
//  ModalLoadingIndicatorContainer.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ModalLoadingIndicatorContainer: Container {
    // MARK: - Lifecycle

    init(
        config: Config,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self.contentObserver = contentObserver
    }

    // MARK: - Internal

    final class Config: ContainerConfig {}

    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(initialParams: InitialParams) {
            self.content = Content(
                indicatorContent: initialParams.indicatorContent
            )
        }

        // MARK: - Internal

        struct Content: ContainerContent {
            let indicatorContent: ParraLoadingIndicatorContent
        }

        struct InitialParams {
            let indicatorContent: ParraLoadingIndicatorContent
        }

        var content: Content

        func dismiss() {}
    }

    var config: Config
    var componentFactory: ComponentFactory
    var contentObserver: ContentObserver

    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea([.top])
        }
        .overlay(alignment: .center) {
            componentFactory.buildLoadingIndicator(
                content: contentObserver.content.indicatorContent,
                onDismiss: contentObserver.dismiss
            )
        }
        .environment(\.parraTheme, parraTheme)
        .environment(componentFactory)
        .environmentObject(contentObserver)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraViewPreview { factory in
        ModalLoadingIndicatorContainer(
            config: .init(),
            componentFactory: factory,
            contentObserver: ModalLoadingIndicatorContainer.ContentObserver(
                initialParams: .init(
                    indicatorContent: ParraLoadingIndicatorContent(
                        title: .init(text: "Loading..."),
                        subtitle: .init(text: "giving it all she's got"),
                        cancel: nil
                    )
                )
            )
        )
    }
}
