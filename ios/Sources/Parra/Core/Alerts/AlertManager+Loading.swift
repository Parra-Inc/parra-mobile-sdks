//
//  AlertManager+Loading.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension ParraAlertManager {
    struct LoadingIndicator: Equatable {
        public let content: ParraLoadingIndicatorContent
        public let attributes: ParraAttributes.LoadingIndicator?
        public let onDismiss: () -> Void
        public let cancel: (() -> Void)?

        public static func == (
            lhs: ParraAlertManager.LoadingIndicator,
            rhs: ParraAlertManager.LoadingIndicator
        ) -> Bool {
            return lhs.content == rhs.content
        }
    }

    @MainActor
    func showLoadingIndicator(
        content: ParraLoadingIndicatorContent,
        attributes: ParraAttributes.LoadingIndicator? = nil,
        cancel: (() -> Void)? = nil
    ) {
        currentLoadingIndicator = LoadingIndicator(
            content: content,
            attributes: attributes,
            onDismiss: dismissLoadingIndicator,
            cancel: cancel
        )
    }

    @MainActor
    func dismissLoadingIndicator() {
        currentLoadingIndicator = nil
    }
}
