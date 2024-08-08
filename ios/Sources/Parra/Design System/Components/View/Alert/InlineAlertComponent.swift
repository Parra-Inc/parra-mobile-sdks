//
//  InlineAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct InlineAlertComponent: View {
    // MARK: - Internal

    let content: ParraAlertContent
    let attributes: ParraAttributes.InlineAlert

    var body: some View {
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
    @EnvironmentObject private var componentFactory: ComponentFactory
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
