//
//  ToastAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ToastAlertComponent: View {
    // MARK: - Internal

    let content: ParraAlertContent
    let attributes: ParraAttributes.ToastAlert
    let onDismiss: () -> Void
    let primaryAction: (() -> Void)?

    var body: some View {
        Button {
            onDismiss()
            primaryAction?()
        } label: {
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
        }
        .applyToastAlertAttributes(
            attributes,
            using: themeObserver.theme
        )
        .overlay(
            ZStack {
                UnevenRoundedRectangle(
                    cornerRadii: themeObserver.theme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .strokeBorder(
                    attributes.border.color ?? .clear,
                    lineWidth: attributes.border.width ?? 0
                )

                if let dismissButtonContent = content.dismiss {
                    VStack {
                        componentFactory.buildImageButton(
                            config: ParraImageButtonConfig(
                                variant: .plain
                            ),
                            content: dismissButtonContent,
                            localAttributes: attributes.dismissButton,
                            onPress: onDismiss
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
                factory.buildToastAlert(
                    level: level,
                    content: ParraAlertContent(
                        title: LabelContent(text: "The task was completed"),
                        subtitle: LabelContent(
                            text: "This is just an FYI. You can go about your day without worrying about anything."
                        ),
                        icon: ParraAlertContent.defaultIcon(for: level),
                        dismiss: ParraAlertContent.defaultDismiss(for: level)
                    ),
                    onDismiss: {}
                )

                Spacer()
            }

            Spacer()
        }
        .padding()
    }
}
