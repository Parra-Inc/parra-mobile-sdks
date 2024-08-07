//
//  LoadingIndicatorComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct LoadingIndicatorComponent: View {
    // MARK: - Internal

    let content: ParraLoadingIndicatorContent
    let attributes: ParraAttributes.LoadingIndicator
    let onDismiss: () -> Void
    let cancel: (() -> Void)?

    var body: some View {
        VStack {
            ProgressView()
                .padding(.top, 6)
                .padding(.bottom, 10)
                .controlSize(.regular)

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

            if let cancelContent = content.cancel, let cancel {
                componentFactory
                    .buildPlainButton(
                        config: ParraTextButtonConfig(
                            type: .primary,
                            size: .small,
                            isMaxWidth: false
                        ),
                        content: cancelContent,
                        localAttributes: ParraAttributes.PlainButton(
                        ),
                        onPress: cancel
                    )
            }
        }
        .applyLoadingIndicatorAlertAttributes(
            attributes,
            using: themeManager.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var componentFactory: ComponentFactory
}

#Preview {
    ParraViewPreview { factory in
        VStack(spacing: 16) {
            Spacer()
            Spacer()

            ForEach(ParraAlertLevel.allCases, id: \.self) { _ in
                factory.buildLoadingIndicator(
                    content:
                    ParraLoadingIndicatorContent(
                        title: ParraLabelContent(text: "Loading..."),
                        subtitle: ParraLabelContent(
                            text: "This should only take a few seconds"
                        ),
                        cancel: .init(text: "Cancel")
                    ),
                    onDismiss: {},
                    cancel: {}
                )

                Spacer()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.1))
    }
}
