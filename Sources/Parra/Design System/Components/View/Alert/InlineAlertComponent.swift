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
                if let icon = content.icon {
                    ImageComponent(
                        content: icon,
                        attributes: attributes.icon
                    )
                }

                componentFactory.buildLabel(
                    fontStyle: .headline,
                    content: content.title,
                    localAttributes: attributes.title
                )
            }

            if let subtitleContent = content.subtitle {
                componentFactory.buildLabel(
                    fontStyle: .subheadline,
                    content: subtitleContent,
                    localAttributes: attributes.subtitle
                )
            }
        }
        .applyInlineAlertAttributes(
            attributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
}

#Preview {
    ParraViewPreview { factory in
        VStack(spacing: 16) {
            Spacer()
            Spacer()

            ForEach(AlertLevel.allCases, id: \.self) { level in
                factory.buildInlineAlert(
                    level: level,
                    content: ParraAlertContent(
                        title: LabelContent(text: "The task was completed"),
                        subtitle: LabelContent(
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
