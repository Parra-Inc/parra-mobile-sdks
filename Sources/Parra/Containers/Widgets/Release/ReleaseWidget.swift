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
        config: ChangelogWidgetConfig,
        style: ChangelogWidgetStyle,
        localBuilderConfig: ChangelogWidgetBuilderConfig,
        componentFactory: ComponentFactory,
        contentObserver: ReleaseContentObserver
    ) {
        self.config = config
        self.style = style
        self.localBuilderConfig = localBuilderConfig
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
                    networkManager: contentObserver.networkManager
                )
            )
        )
    }

    // MARK: - Internal

    let localBuilderConfig: ChangelogWidgetBuilderConfig
    let componentFactory: ComponentFactory

    @StateObject var contentObserver: ReleaseContentObserver
    let config: ChangelogWidgetConfig
    let style: ChangelogWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

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
                config: config.releaseDetailTitle,
                content: contentObserver.content.title,
                suppliedBuilder: localBuilderConfig.releaseDetailTitle,
                localAttributes: style.releaseDetailTitle
            )

            withContent(content: contentObserver.content.subtitle) { content in
                componentFactory.buildLabel(
                    config: config.releaseDetailSubtitle,
                    content: content,
                    suppliedBuilder: localBuilderConfig.releaseDetailSubtitle,
                    localAttributes: style.releaseDetailSubtitle
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                componentFactory.buildTextButton(
                    variant: .contained,
                    config: config.releaseDetailShowOtherReleasesButton,
                    content: content,
                    suppliedBuilder: localBuilderConfig
                        .releaseDetailShowOtherReleasesButton,
                    onPress: {
                        navigationState.navigationPath.append("changelog")
                    }
                )
            }
        }
    }

    @ViewBuilder var primaryContent: some View {
        let content = contentObserver.content

        GeometryReader { geometry in
            let width = Double.maximum(
                geometry.size.width
                    - style.contentPadding.leading
                    - style.contentPadding.trailing,
                0.0
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 20.0) {
                    header

                    withContent(
                        content: content.header
                    ) { content in
                        let aspectRatio = content.size.width / content.size
                            .height

                        AsyncImageComponent(
                            content: content.image,
                            attributes: style.releaseDetailHeaderImage
                        )
                        .aspectRatio(aspectRatio, contentMode: .fill)
                        .frame(
                            width: width,
                            height: (width / aspectRatio).rounded()
                        )
                    }

                    withContent(
                        content: content.description
                    ) { content in
                        componentFactory.buildLabel(
                            config: config.releaseDetailDescription,
                            content: content,
                            suppliedBuilder: localBuilderConfig
                                .releaseDetailDescription,
                            localAttributes: style.releaseDetailDescription
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
            style.contentPadding,
            for: .scrollContent
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            primaryContent

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(style.background)
        .task {
            await contentObserver.loadSections()
        }
        .environment(config)
        .environment(localBuilderConfig)
        .environmentObject(contentObserver)
        .environmentObject(componentFactory)
        // required to prevent navigation bar from changing colors when scrolled
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: String.self) { destination in
            if destination == "changelog" {
                ChangelogWidget(
                    config: config,
                    style: style,
                    localBuilderConfig: localBuilderConfig,
                    componentFactory: componentFactory,
                    contentObserver: changelogContentObserver
                )
                .padding(.top, 40)
                .edgesIgnoringSafeArea([.top])
                .environmentObject(navigationState)
            }
        }
    }

    // MARK: - Private

    @StateObject private var changelogContentObserver: ChangelogWidget
        .ContentObserver

    @EnvironmentObject private var navigationState: NavigationState
}
