//
//  ParraEmptyStateComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraEmptyStateComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraEmptyStateConfig,
        content: ParraEmptyStateContent,
        attributes: ParraAttributes.EmptyState,
        onPrimaryAction: (() -> Void)?,
        onSecondaryAction: (() -> Void)?
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    // MARK: - Public

    public let config: ParraEmptyStateConfig
    public let content: ParraEmptyStateContent
    public let attributes: ParraAttributes.EmptyState
    public let onPrimaryAction: (() -> Void)?
    public let onSecondaryAction: (() -> Void)?

    public var body: some View {
        VStack(alignment: .center) {
            Spacer()

            VStack(spacing: 0) {
                withContent(
                    content: content.icon
                ) { content in

                    componentFactory.buildImage(
                        content: content,
                        localAttributes: attributes.icon
                    )
                    .aspectRatio(contentMode: .fit)
                }

                componentFactory.buildLabel(
                    content: content.title,
                    localAttributes: attributes.titleLabel
                )

                withContent(
                    content: content.subtitle
                ) { content in
                    componentFactory.buildLabel(
                        content: content,
                        localAttributes: attributes.subtitleLabel
                    )
                }

                VStack(spacing: 0) {
                    withContent(
                        content: content.primaryAction
                    ) { content in
                        componentFactory.buildContainedButton(
                            config: config.primaryAction,
                            content: content,
                            localAttributes: attributes.primaryActionButton,
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
                            localAttributes: attributes.secondaryActionButton,
                            onPress: {
                                onSecondaryAction?()
                            }
                        )
                    }
                }
            }
            .applyEmptyStateAttributes(
                attributes,
                using: parraTheme
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(attributes.background)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraViewPreview { factory in
        factory.buildEmptyState(
            config: .default,
            content: .preview
        )
    }
}
