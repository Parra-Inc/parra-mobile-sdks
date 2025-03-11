//
//  CreatorUpdateWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct CreatorUpdateWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraCreatorUpdateConfiguration,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)

        _navigationPath = navigationPath
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    @Binding var navigationPath: NavigationPath

    let config: ParraCreatorUpdateConfiguration

    var body: some View {
        CreatorUpdateTemplatePickerView(
            templates: contentObserver.templates,
            contentObserver: contentObserver
        )
        .navigationTitle("Choose a Template")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(
            item: $contentObserver.creatorUpdate
        ) { creatorUpdate in
            CreatorUpdateComposerView(
                creatorUpdate: creatorUpdate,
                contentObserver: _contentObserver
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
}

#Preview {
    ParraContainerPreview<FeedWidget>(
        config: .default
    ) { parra, _, config in
        FeedWidget(
            config: .default,
            contentObserver: .init(
                initialParams: FeedWidget.ContentObserver
                    .InitialParams(
                        feedId: "test-feed-id",
                        config: .default,
                        feedCollectionResponse: .validStates()[0],
                        api: parra.parraInternal.api
                    )
            ),
            navigationPath: .constant(.init())
        )
    }
}
