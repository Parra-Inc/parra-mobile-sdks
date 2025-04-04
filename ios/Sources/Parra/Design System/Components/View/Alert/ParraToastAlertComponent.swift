//
//  ParraToastAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraToastAlertComponent: View {
    // MARK: - Lifecycle

    init(
        content: ParraAlertContent,
        attributes: ParraAttributes.ToastAlert,
        onDismiss: @escaping () -> Void,
        primaryAction: (() -> Void)?
    ) {
        self.content = content
        self.attributes = attributes
        self.onDismiss = onDismiss
        self.primaryAction = primaryAction
    }

    // MARK: - Public

    public let content: ParraAlertContent
    public let attributes: ParraAttributes.ToastAlert
    public let onDismiss: () -> Void
    public let primaryAction: (() -> Void)?

    public var body: some View {
        Button {
            onDismiss()
            primaryAction?()
        } label: {
            HStack(alignment: .top, spacing: 11) {
                withContent(
                    content: content.icon
                ) { content in
                    componentFactory.buildImage(
                        content: content,
                        localAttributes: attributes.icon
                    )
                }

                VStack {
                    componentFactory.buildLabel(
                        content: content.title,
                        localAttributes: attributes.title
                    )

                    if let subtitleContent = content.subtitle {
                        componentFactory.buildLabel(
                            content: subtitleContent,
                            localAttributes: attributes.subtitle
                        )
                    }
                }
            }
        }
        .applyToastAlertAttributes(
            attributes,
            using: parraTheme
        )
        .overlay(
            ZStack {
                UnevenRoundedRectangle(
                    cornerRadii: parraTheme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .strokeBorder(
                    attributes.border.color ?? .clear,
                    lineWidth: attributes.border.width ?? 0
                )

                if let dismissButtonContent = content.dismiss {
                    VStack {
                        Spacer()

                        componentFactory.buildImageButton(
                            config: ParraImageButtonConfig(
                                variant: .plain
                            ),
                            content: dismissButtonContent,
                            localAttributes: attributes.dismissButton,
                            onPress: onDismiss
                        )

                        Spacer()
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .trailing
                    )
                }
            }
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
                factory.buildToastAlert(
                    level: level,
                    content: ParraAlertContent(
                        title: ParraLabelContent(text: "The task was completed"),
                        subtitle: ParraLabelContent(
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
