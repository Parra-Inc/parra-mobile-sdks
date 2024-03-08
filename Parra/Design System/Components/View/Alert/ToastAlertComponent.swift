//
//  ToastAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ToastAlertComponent: AlertComponentType {
    // MARK: - Lifecycle

    init(
        config: AlertConfig,
        content: AlertContent,
        style: ParraAttributedAlertStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: - Internal

    let config: AlertConfig
    let content: AlertContent
    let style: ParraAttributedAlertStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver
    @EnvironmentObject var componentFactory: ComponentFactory

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
        .overlay(
            ZStack {
                UnevenRoundedRectangle(
                    cornerRadii: themeObserver.theme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .strokeBorder(
                    attributes.borderColor ?? .clear,
                    lineWidth: attributes.borderWidth ?? 0
                )

                if let dismissButtonContent = content.dismiss {
                    VStack {
                        componentFactory.buildImageButton(
                            variant: config.dismiss.variant,
                            config: config.dismiss,
                            content: dismissButtonContent,
                            localAttributes: attributes.dismiss
                        )
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topTrailing
                    )
                }
            }
        )
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack(spacing: 16) {
            Spacer()
            Spacer()

            ForEach(AlertConfig.Style.allCases, id: \.self) { style in
                factory.buildAlert(
                    variant: .toast,
                    config: AlertConfig(style: style),
                    content: AlertContent(
                        title: LabelContent(text: "The task was completed"),
                        subtitle: LabelContent(
                            text: "This is just an FYI. You can go about your day without worrying about anything."
                        ),
                        icon: AlertContent.defaultIcon(for: style),
                        dismiss: AlertContent.defaultDismiss(for: style)
                    )
                )

                Spacer()
            }

            Spacer()
        }
        .padding()
    }
}
