//
//  EmptyStateComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct EmptyStateComponent: EmptyStateComponentType {
    // MARK: - Lifecycle

    init(
        config: EmptyStateConfig,
        content: EmptyStateContent,
        style: ParraAttributedEmptyStateStyle,
        onPrimaryAction: (() -> Void)? = nil,
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.config = config
        self.content = content
        self.style = style
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    // MARK: - Internal

    let config: EmptyStateConfig
    let content: EmptyStateContent
    let style: ParraAttributedEmptyStateStyle
    let onPrimaryAction: (() -> Void)?
    let onSecondaryAction: (() -> Void)?

    var body: some View {
        let attributes = style.attributes

        VStack(alignment: .center) {
            Spacer()

            VStack(spacing: 0) {
                withContent(
                    content: content.icon,
                    style: style.iconAttributes
                ) { content, attributes in
                    ImageComponent(
                        content: content,
                        attributes: attributes
                    )
                    .aspectRatio(contentMode: .fit)
                }

                componentFactory.buildLabel(
                    config: config.title,
                    content: content.title,
                    localAttributes: style.titleStyle.attributes
                )

                withContent(
                    content: content.subtitle,
                    style: style.subtitleStyle
                ) { content, style in
                    componentFactory.buildLabel(
                        config: config.subtitle,
                        content: content,
                        localAttributes: style.attributes
                    )
                    .multilineTextAlignment(.center)
                }

                VStack(spacing: 0) {
                    withContent(
                        content: content.primaryAction,
                        style: style.primaryActionStyle
                    ) { content, style in
                        componentFactory.buildTextButton(
                            variant: .contained,
                            config: config.primaryAction,
                            content: content,
                            localAttributes: style.attributes,
                            onPress: {
                                onPrimaryAction?()
                            }
                        )
                    }

                    withContent(
                        content: content.secondaryAction,
                        style: style.secondaryActionStyle
                    ) { content, style in
                        componentFactory.buildTextButton(
                            variant: .plain,
                            config: config.secondaryAction,
                            content: content,
                            localAttributes: style.attributes,
                            onPress: {
                                onSecondaryAction?()
                            }
                        )
                    }
                }
            }
            .padding(attributes.padding ?? .zero)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(attributes.background)
    }

    // MARK: - Private

    @EnvironmentObject private var componentFactory: ComponentFactory
}

#Preview {
    ParraViewPreview { factory in
        factory.buildEmptyState(
            config: .default,
            content: .preview
        )
    }
}
