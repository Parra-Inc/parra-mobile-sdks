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

    let content: AlertContent

    var body: some View {
        VStack {
            HStack(spacing: 11) {
                if let icon = content.icon {
                    ImageComponent(
                        content: icon,
                        attributes: ParraAttributes.Image()
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
//        .padding(.all, from: attributes.padding ?? .zero)
//        .applyBackground(attributes.background)
//        .applyCornerRadii(
//            size: attributes.cornerRadius,
//            from: themeObserver.theme
//        )
//        .applyBorder(
//            borderColor: attributes.borderColor ?? .clear,
//            borderWidth: attributes.borderWidth,
//            cornerRadius: attributes.cornerRadius,
//            from: themeObserver.theme
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
                    variant: .inline,
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
