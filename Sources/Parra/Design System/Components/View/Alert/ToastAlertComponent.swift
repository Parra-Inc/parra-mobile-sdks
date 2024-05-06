//
//  ToastAlertComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ToastAlertComponent: AlertComponentType {
    // MARK: - Internal

    let content: AlertContent
    let onDismiss: () -> Void

    let primaryAction: (() -> Void)?

    var body: some View {
        Button {
            onDismiss()
            primaryAction?()
        } label: {
            VStack {
                HStack(spacing: 11) {
                    if let icon = content.icon {
                        ImageComponent(
                            content: icon,
                            attributes: .init()
                        )
                    }

                    componentFactory.buildLabel(
                        fontStyle: .headline,
                        content: content.title
                    )
                }

                if let subtitleContent = content.subtitle {
                    componentFactory.buildLabel(
                        fontStyle: .subheadline,
                        content: subtitleContent
                    )
                }
            }
        }
//        .padding(.all, from: attributes.padding ?? .zero)
//        .applyBackground(attributes.background)
//        .applyCornerRadii(
//            size: attributes.cornerRadius,
//            from: themeObserver.theme
//        )
//        .overlay(
//            ZStack {
//                UnevenRoundedRectangle(
//                    cornerRadii: themeObserver.theme.cornerRadius
//                        .value(for: attributes.cornerRadius)
//                )
//                .strokeBorder(
//                    attributes.borderColor ?? .clear,
//                    lineWidth: attributes.borderWidth ?? 0
//                )
//
//                if let dismissButtonContent = content.dismiss {
//                    VStack {
//                        componentFactory.buildImageButton(
//                            variant: .plain,
//                            config: .init(),
//                            content: dismissButtonContent,
//                            localAttributes: attributes.dismiss,
//                            onPress: onDismiss
//                        )
//                        .frame(width: 12, height: 12)
//                    }
//                    .frame(
//                        maxWidth: .infinity,
//                        maxHeight: .infinity,
//                        alignment: .topTrailing
//                    )
//                }
//            }
//        )
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
                factory.buildAlert(
                    variant: .toast(onDismiss: {}),
                    level: level,
                    content: AlertContent(
                        title: LabelContent(text: "The task was completed"),
                        subtitle: LabelContent(
                            text: "This is just an FYI. You can go about your day without worrying about anything."
                        ),
                        icon: AlertContent.defaultIcon(for: level),
                        dismiss: AlertContent.defaultDismiss(for: level)
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
