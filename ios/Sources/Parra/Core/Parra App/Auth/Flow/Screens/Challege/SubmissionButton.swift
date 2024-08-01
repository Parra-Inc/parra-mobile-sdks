//
//  SubmissionButton.swift
//  Parra
//
//  Created by Mick MacCallum on 6/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct SubmissionButton: View {
    // MARK: - Lifecycle

    init(
        config: ParraTextButtonConfig,
        variant: ParraButtonVariant,
        content: TextButtonContent,
        onPress: @escaping () async -> Void
    ) {
        self.config = config
        self.variant = variant
        self.content = content
        self.onPress = onPress
    }

    // MARK: - Internal

    let config: ParraTextButtonConfig
    let variant: ParraButtonVariant
    @State var content: TextButtonContent

    let onPress: () async -> Void

    var body: some View {
        switch variant {
        case .plain:
            componentFactory.buildPlainButton(
                config: config,
                content: content,
                localAttributes: .init(
                    normal: .init(
                        padding: .zero
                    )
                ),
                onPress: handlePress
            )
        case .outlined:
            componentFactory.buildOutlinedButton(
                config: config,
                content: content,
                localAttributes: .init(
                    normal: .init(
                        padding: .zero
                    )
                ),
                onPress: handlePress
            )
        case .contained:
            componentFactory.buildContainedButton(
                config: config,
                content: content,
                localAttributes: .init(
                    normal: .init(
                        padding: .zero
                    )
                ),
                onPress: handlePress
            )
        }
    }

    // MARK: - Private

    @EnvironmentObject private var componentFactory: ComponentFactory

    private func handlePress() {
        content = content.withLoading(true)

        Task {
            await onPress()

            Task { @MainActor in
                content = content.withLoading(false)
            }
        }
    }
}
