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
                    fontStyle: .title,
                    content: content.title
                )

                withContent(
                    content: content.subtitle
                ) { content in
                    componentFactory.buildLabel(
                        fontStyle: .subheadline,
                        content: content
                    )
                    .multilineTextAlignment(.center)
                }

                VStack(spacing: 0) {
                    withContent(
                        content: content.primaryAction
                    ) { content in
                        componentFactory.buildContainedButton(
                            config: config.primaryAction,
                            content: content,
                            onPress: {
                                onPrimaryAction?()
                            }
                        )
                    }

                    withContent(
                        content: content.secondaryAction
                    ) { content in
                        componentFactory.buildPlainButton(
                            config: config.secondaryAction,
                            content: content,
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
