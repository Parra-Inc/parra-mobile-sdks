//
//  ReleaseWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// struct ParraUsernameView: View {
//
//    @EnvironmentObject var componentFactory: ComponentFactory
//    @EnvironmentObject var themeObserver: ParraThemeObserver
//
//    @Environment(\.parraAuthState) var parraAuth
//
//    let fontStyle: Font.TextStyle
//    let localAttributes: LabelAttributes?
//
//    var body: some View {
//        switch parraAuth.current {
//        case .authenticated(let user):
//            componentFactory.buildLabel(
//                config: .init(fontStyle: fontStyle),
//                content: LabelContent(text: user.userInfo?.name ?? "-"),
//                localAttributes: localAttributes
//            )
//        case .unauthenticated:
//            Text("-")
//        }
//    }
//
// }
//
// HStack {
////    ParraAvatarView()
//
//    VStack {
//        ParraUsernameView(fontStyle: .title)
//            .background(.red)
//            .font(.headline)
//
//        //.. Email
//    }
// }

struct ReleaseWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ChangelogWidgetConfig,
        style: ChangelogWidgetStyle,
        componentFactory: ComponentFactory,
        contentObserver: ReleaseContentObserver
    ) {
        self.config = config
        self.style = style
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
                fontStyle: .title,
                content: contentObserver.content.title
            )

            withContent(content: contentObserver.content.subtitle) { content in
                componentFactory.buildLabel(
                    fontStyle: .subheadline,
                    content: content
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
                    config: TextButtonConfig(
                        style: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: content,
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
                            attributes: ParraAttributes.Image(
                                cornerRadius: .sm
                            )
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
                            fontStyle: .body,
                            content: content
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
        .environmentObject(contentObserver)
        .environmentObject(componentFactory)
        // required to prevent navigation bar from changing colors when scrolled
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: String.self) { destination in
            if destination == "changelog" {
                ChangelogWidget(
                    config: config,
                    style: style,
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
