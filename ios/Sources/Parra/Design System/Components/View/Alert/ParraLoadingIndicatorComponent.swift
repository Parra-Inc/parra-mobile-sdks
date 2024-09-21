//
//  ParraLoadingIndicatorComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLoadingIndicatorComponent: View {
    // MARK: - Lifecycle

    init(
        content: ParraLoadingIndicatorContent,
        attributes: ParraAttributes.LoadingIndicator,
        onDismiss: @escaping () -> Void,
        cancel: (() -> Void)?
    ) {
        self.content = content
        self.attributes = attributes
        self.onDismiss = onDismiss
        self.cancel = cancel
    }

    // MARK: - Public

    public let content: ParraLoadingIndicatorContent
    public let attributes: ParraAttributes.LoadingIndicator
    public let onDismiss: () -> Void
    public let cancel: (() -> Void)?

    public var body: some View {
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
            using: parraTheme
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(ParraComponentFactory.self) private var componentFactory
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
