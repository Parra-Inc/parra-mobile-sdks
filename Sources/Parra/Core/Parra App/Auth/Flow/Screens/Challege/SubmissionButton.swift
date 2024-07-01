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
        onPress: @escaping () async throws -> Void
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

    let onPress: () async throws -> Void

    var body: some View {
        componentFactory.buildButton(
            variant: variant,
            config: config,
            content: content,
            onPress: handlePress
        )
    }

    // MARK: - Private

    @EnvironmentObject private var componentFactory: ComponentFactory

    private func handlePress() {
        content = content.withLoading(true)

        Task {
            do {
                defer {
                    Task { @MainActor in
                        content = content.withLoading(false)
                    }
                }

                try await onPress()
            }
        }
    }
}
