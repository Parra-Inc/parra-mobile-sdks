//
//  ParraInlineAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraInlineAlertComponent: View {
    // MARK: - Lifecycle

    init(
        content: ParraAlertContent,
        attributes: ParraAttributes.InlineAlert
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Public

    public let content: ParraAlertContent
    public let attributes: ParraAttributes.InlineAlert

    public var body: some View {
        VStack {
            HStack(spacing: 11) {
                withContent(
                    content: content.icon
                ) { content in
                    componentFactory.buildImage(
                        content: content,
                        localAttributes: attributes.icon
                    )
                }

                componentFactory.buildLabel(
                    content: content.title,
                    localAttributes: attributes.title
                )
            }

            if let subtitleContent = content.subtitle {
                componentFactory.buildLabel(
                    content: subtitleContent,
                    localAttributes: attributes.subtitle
                )
            }
        }
        .applyInlineAlertAttributes(
            attributes,
            using: parraTheme
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory
}

#Preview {
    ParraViewPreview { factory in
        VStack(spacing: 16) {
            Spacer()
            Spacer()

            ForEach(ParraAlertLevel.allCases, id: \.self) { level in
                factory.buildInlineAlert(
                    level: level,
                    content: ParraAlertContent(
                        title: ParraLabelContent(text: "The task was completed"),
                        subtitle: ParraLabelContent(
                            text: "This is just an FYI. You can go about your day without worrying about anything."
                        ),
                        icon: ParraAlertContent.defaultIcon(for: level),
                        dismiss: ParraAlertContent.defaultDismiss(for: level)
                    )
                )

                Spacer()
            }

            Spacer()
        }
        .padding()
    }
}
