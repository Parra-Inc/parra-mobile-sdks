//
//  InlineAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct InlineAlertComponent: AlertComponentType {
    // MARK: - Internal

    let config: AlertConfig
    let content: AlertContent
    let style: ParraAttributedAlertStyle

    var body: some View {
        let attributes = style.attributes

        VStack {
            HStack(spacing: 11) {
                if let icon = content.icon {
                    ImageComponent(
                        content: icon,
                        attributes: attributes.icon
                    )
                }

                componentFactory.buildLabel(
                    config: config.title,
                    content: content.title,
                    localAttributes: style.attributes.title
                )
                .multilineTextAlignment(.leading)
            }

            if let subtitleContent = content.subtitle {
                componentFactory.buildLabel(
                    config: config.subtitle,
                    content: subtitleContent,
                    localAttributes: style.attributes.subtitle
                )
                .multilineTextAlignment(.leading)
            }
        }
        .padding(.all, from: attributes.padding ?? .zero)
        .applyBackground(attributes.background)
        .applyCornerRadii(
            size: attributes.cornerRadius,
            from: themeObserver.theme
        )
        .applyBorder(
            borderColor: attributes.borderColor ?? .clear,
            borderWidth: attributes.borderWidth,
            cornerRadius: attributes.cornerRadius,
            from: themeObserver.theme
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

            ForEach(AlertConfig.Style.allCases, id: \.self) { style in
                factory.buildAlert(
                    variant: .inline,
                    config: AlertConfig(style: style),
                    content: AlertContent(
                        title: LabelContent(text: "The task was completed"),
                        subtitle: LabelContent(
                            text: "This is just an FYI. You can go about your day without worrying about anything."
                        ),
                        icon: AlertContent.defaultIcon(for: style),
                        dismiss: AlertContent.defaultDismiss(for: style)
                    ),
                    primaryAction: nil
                )

                Spacer()
            }

            Spacer()
        }
        .padding()
    }
}
