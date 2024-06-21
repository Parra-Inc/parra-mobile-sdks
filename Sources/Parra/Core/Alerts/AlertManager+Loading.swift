//
//  AlertManager+Loading.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

extension AlertManager {
    struct LoadingIndicator: Equatable {
        let content: ParraLoadingIndicatorContent
        let attributes: ParraAttributes.LoadingIndicator?
        let onDismiss: () -> Void
        let cancel: (() -> Void)?

        static func == (
            lhs: AlertManager.LoadingIndicator,
            rhs: AlertManager.LoadingIndicator
        ) -> Bool {
            return lhs.content == rhs.content
        }
    }

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

    func dismissLoadingIndicator() {
        currentLoadingIndicator = nil
    }
}
