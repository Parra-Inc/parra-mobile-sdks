//
//  ParraLabelComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLabelComponent: View {
    // MARK: - Lifecycle

    init(
        content: ParraLabelContent,
        attributes: ParraAttributes.Label
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Public

    public let content: ParraLabelContent
    public let attributes: ParraAttributes.Label

    public var body: some View {
        labelElement
            .applyFrame(attributes.frame)
            .applyLabelAttributes(
                attributes,
                using: parraTheme
            )
            .contentShape(.rect)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var textElement: some View {
        Text(content.text)
            .applyTextAttributes(
                attributes.text,
                using: parraTheme
            )
    }

    @ViewBuilder private var labelElement: some View {
        // Avoid using Label when possible since it is heavier to render.
        if content.isLoading || content.icon != nil {
            Label(
                title: {
                    textElement
                },
                icon: {
                    if content.isLoading {
                        ProgressView()
                            .tint(attributes.text.color ?? .black)
                    } else {
                        withContent(
                            content: content.icon
                        ) { content in
                            componentFactory.buildImage(
                                content: content,
                                localAttributes: attributes.icon
                            )
                            // Need to override resizable modifier from
                            // general implementation.
                            .fixedSize()
                        }
                    }
                }
            )
        } else {
            Text(content.text)
                .applyTextAttributes(
                    attributes.text,
                    using: parraTheme
                )
        }
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack(alignment: .leading, spacing: 16) {
            factory.buildLabel(
                content: ParraLabelContent(text: "Default config"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .body
                    )
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "A large title"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .largeTitle,
                        weight: .heavy
                    )
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "A large title 2"),
                localAttributes: .default(with: .largeTitle)
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "A subheadline"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .subheadline
                    )
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(
                    text: "A subheadline with icon",
                    icon: .symbol("sun.rain.circle.fill")
                ),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .subheadline
                    )
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "With a background"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .body,
                        color: .green
                    ),
                    background: .red
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "max width"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        color: .white,
                        shadow: ParraAttributes.Shadow(
                            color: .white, radius: 6, x: 0, y: 0
                        )
                    ),
                    cornerRadius: .md,
                    padding: .md,
                    background: .blue,
                    frame: .flexible(
                        FlexibleFrameAttributes(
                            maxWidth: .infinity
                        )
                    )
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "custom width"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        color: .white,
                        shadow: ParraAttributes.Shadow(
                            color: .white, radius: 6, x: 0, y: 0
                        )
                    ),
                    cornerRadius: .md,
                    padding: .md,
                    background: .blue,
                    frame: .flexible(
                        FlexibleFrameAttributes(
                            minWidth: 240
                        )
                    )
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "With a gradient background"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title,
                        color: .green
                    ),
                    cornerRadius: .md,
                    padding: .custom(
                        .padding(
                            top: 4,
                            leading: 20,
                            bottom: 20,
                            trailing: 10
                        )
                    ),
                    background: .purple
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(
                    text: "BG and icon",
                    icon: .symbol("fireworks")
                ),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title,
                        color: .white
                    ),
                    icon: ParraAttributes.Image(
                        tint: .white
                    ),
                    cornerRadius: .xxl,
                    padding: .custom(
                        .padding(
                            top: 4,
                            leading: 10,
                            bottom: 4,
                            trailing: 10
                        )
                    ),
                    background: .pink
                )
            )

            factory.buildLabel(
                content: ParraLabelContent(text: "With a corner radius"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .subheadline
                    ),
                    cornerRadius: .lg,
                    padding: .lg,
                    background: .green
                )
            )
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
