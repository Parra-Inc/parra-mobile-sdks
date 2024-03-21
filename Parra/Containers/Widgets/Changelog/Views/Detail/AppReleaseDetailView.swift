//
//  AppReleaseDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseDetailView: View {
    @StateObject var contentObserver: AppReleaseContentObserver

    let style: ChangelogWidgetStyle

    @Environment(ChangelogWidgetConfig.self) var config
    @Environment(ChangelogWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var componentFactory: ComponentFactory

    var sections: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(contentObserver.content.sections) { section in
                ChangelogSectionView(content: section)
            }
            .disabled(contentObserver.isLoading)
        }
        .padding(.top, 6)
        .redacted(
            when: contentObserver.isLoading
        )
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            // What "What's new" case
            componentFactory.buildLabel(
                config: config.releaseDetailTitle,
                content: contentObserver.content.title,
                suppliedBuilder: builderConfig.releaseDetailTitle,
                localAttributes: style.releaseDetailTitle
            )

            withContent(content: contentObserver.content.subtitle) { content in
                componentFactory.buildLabel(
                    config: config.releaseDetailSubtitle,
                    content: content,
                    suppliedBuilder: builderConfig.releaseDetailSubtitle,
                    localAttributes: style.releaseDetailSubtitle
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ChangelogItemInfoView(
                content: contentObserver.content
            )
        }
    }

    var body: some View {
        let content = contentObserver.content

        GeometryReader { geometry in
            let width = Double.maximum(
                geometry.size.width
                    - style.contentPadding.leading
                    - style.contentPadding.trailing,
                0.0
            )

            VStack(spacing: 0) {
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
                                suppliedBuilder: builderConfig
                                    .releaseDetailDescription,
                                localAttributes: style.releaseDetailDescription
                            )
                            .multilineTextAlignment(.leading)
                        }

                        sections
                    }
                }
                .contentMargins(
                    .all,
                    style.contentPadding,
                    for: .scrollContent
                )

                WidgetFooter {}
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(style.background)
        .task {
            await contentObserver.loadSections()
        }
    }
}
