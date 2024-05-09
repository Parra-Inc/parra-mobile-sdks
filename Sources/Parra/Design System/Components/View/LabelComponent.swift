//
//  LabelComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct LabelComponent: View {
    // MARK: - Lifecycle

    init(
        content: LabelContent,
        attributes: ParraAttributes.Label
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let content: LabelContent
    let attributes: ParraAttributes.Label

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Label(
            title: {
                Text(content.text)
                    .applyFrame(attributes.frame)
                    .applyTextAttributes(
                        attributes.text,
                        using: themeObserver.theme
                    )
            },
            icon: {
                if content.isLoading {
                    ProgressView()
                        .tint(attributes.text.color ?? .black)
                } else {
                    withContent(
                        content: content.icon
                    ) { content in
                        ImageComponent(
                            content: content,
                            attributes: attributes.icon
                        )
                        // Need to override resizable modifier from
                        // general implementation.
                        .fixedSize()
                    }
                }
            }
        )
        .applyLabelAttributes(
            attributes,
            using: themeObserver.theme
        )
        .contentShape(.rect)
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack(alignment: .leading, spacing: 16) {
            factory.buildLabel(
                fontStyle: .body,
                content: LabelContent(text: "Default config")
            )

            factory.buildLabel(
                fontStyle: .title,
                content: LabelContent(text: "A large title")
            )

            factory.buildLabel(
                fontStyle: .subheadline,
                content: LabelContent(text: "A subheadline")
            )

            factory.buildLabel(
                fontStyle: .subheadline,
                content: LabelContent(
                    text: "A subheadline with icon",
                    icon: .symbol("sun.rain.circle.fill")
                )
            )

            factory.buildLabel(
                fontStyle: .body,
                content: LabelContent(text: "With a background"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        font: .title,
                        color: .green
                    ),
                    background: .red
                )
            )

            factory.buildLabel(
                fontStyle: .title,
                content: LabelContent(text: "With a gradient background"),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        font: .title,
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
                fontStyle: .title,
                content: LabelContent(
                    text: "BG and icon",
                    icon: .symbol("fireworks")
                ),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
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
                fontStyle: .subheadline,
                content: LabelContent(text: "With a corner radius"),
                localAttributes: ParraAttributes.Label(
                    cornerRadius: .lg,
                    padding: .lg,
                    background: .green
                )
            )
        }
    }
}
