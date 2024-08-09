//
//  ReleaseWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ReleaseWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraChangelogWidgetConfig,
        componentFactory: ComponentFactory,
        contentObserver: ReleaseContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)

        let collection: AppReleaseCollectionResponse? = if let releaseStub =
            contentObserver.releaseStub
        {
            AppReleaseCollectionResponse(
                page: 0,
                pageCount: .max,
                pageSize: 15,
                totalCount: .max,
                data: [releaseStub]
            )
        } else {
            nil
        }

        self._changelogContentObserver = StateObject(
            wrappedValue: ChangelogWidget.ContentObserver(
                initialParams: .init(
                    appReleaseCollection: collection,
                    api: contentObserver.api
                )
            )
        )
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory

    @StateObject var contentObserver: ReleaseContentObserver
    @StateObject var changelogContentObserver: ChangelogWidget
        .ContentObserver

    let config: ParraChangelogWidgetConfig

    var sections: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(contentObserver.content.sections) { section in
                ReleaseChangelogSectionView(content: section)
            }
            .disabled(contentObserver.isLoading)
        }
        .padding(.top, 6)
        .redacted(
            when: contentObserver.isLoading
        )
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            componentFactory.buildLabel(
                content: contentObserver.content.title,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title
                    )
                )
            )

            withContent(content: contentObserver.content.subtitle) { content in
                componentFactory.buildLabel(
                    content: content,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .subheadline,
                            alignment: .leading
                        ),
                        frame: .flexible(
                            FlexibleFrameAttributes(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        )
                    )
                )
            }

            ChangelogItemInfoView(
                content: contentObserver.content
            )
            .padding(.top, 8)
        }
    }

    @ViewBuilder var footer: some View {
        WidgetFooter {
            withContent(
                content: contentObserver.content.otherReleasesButton
            ) { content in
                componentFactory.buildContainedButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: content.withLoading(
                        changelogContentObserver.releasePaginator.isLoading
                    ),
                    onPress: {
                        navigationState.navigationPath.append("changelog")
                    }
                )
            }
        }
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(spacing: 0) {
            primaryContent(with: contentPadding)

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .task {
            await contentObserver.loadSections()

            // If there isn't a button to navigate to other releases, don't load
            // them.
            if contentObserver.content.otherReleasesButton != nil {
                changelogContentObserver.loadInitialReleases()
            }
        }
        .environment(config)
        .environmentObject(contentObserver)
        .environmentObject(componentFactory)
        // required to prevent navigation bar from changing colors when scrolled
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: String.self) { destination in
            if destination == "changelog" {
                ChangelogWidget(
                    config: config,
                    componentFactory: componentFactory,
                    contentObserver: changelogContentObserver
                )
                .padding(.top, 40)
                .edgesIgnoringSafeArea([.top])
                .environmentObject(navigationState)
            }
        }
    }

    @ViewBuilder
    func primaryContent(
        with contentPadding: EdgeInsets
    ) -> some View {
        let content = contentObserver.content

        GeometryReader { geometry in
            let width = Double.maximum(
                geometry.size.width
                    - contentPadding.leading
                    - contentPadding.trailing,
                0.0
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 20.0) {
                    header

                    withContent(
                        content: content.header
                    ) { content in
                        let aspectRatio = UIDevice.isIpad ? 2.5
                            : content.size.width / content.size.height

                        componentFactory.buildAsyncImage(
                            config: .init(
                                aspectRatio: aspectRatio,
                                contentMode: .fill
                            ),
                            content: content.image,
                            localAttributes: ParraAttributes.AsyncImage(
                                cornerRadius: .sm,
                                background: parraTheme.palette
                                    .secondaryBackground
                            )
                        )
                        .frame(
                            width: width,
                            height: (width / aspectRatio).rounded()
                        )
                    }

                    withContent(
                        content: content.description
                    ) { content in
                        componentFactory.buildLabel(
                            content: content,
                            localAttributes: ParraAttributes.Label(
                                text: ParraAttributes.Text(
                                    style: .body,
                                    alignment: .leading
                                )
                            )
                        )
                        .multilineTextAlignment(.leading)
                    }

                    sections
                }
            }
        }
        .clipped()
        .contentMargins(
            [.horizontal, .bottom],
            contentPadding,
            for: .scrollContent
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    @EnvironmentObject private var navigationState: NavigationState
}
