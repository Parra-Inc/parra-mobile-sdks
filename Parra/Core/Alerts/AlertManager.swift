//
//  AlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class AlertManager: ObservableObject {
    struct Alert: Equatable {
        let config: AlertConfig
        let content: AlertContent
        let attributes: AlertAttributes?

        let duration: TimeInterval
        let animationDuration: TimeInterval
        let location: AlertLocation

        static func == (
            lhs: AlertManager.Alert,
            rhs: AlertManager.Alert
        ) -> Bool {
            return lhs.content == rhs.content
        }
    }

    /// Where the alert/toast should be presented on screen. Note that leading
    /// and trailing alignments are only applicable to iPad. On iPhone all the
    /// top alignments resolve to `topCenter` and all bottom alignments resolve
    /// to `bottomCenter`.
    enum AlertLocation {
        case topCenter
        case topLeading
        case topTrailing
        case bottomCenter
        case bottomLeading
        case bottomTrailing

        // MARK: - Internal

        var toViewAlignment: Alignment {
            let isIpad = UIDevice.isIpad

            switch self {
            case .topCenter:
                return .top
            case .topLeading:
                return isIpad ? .topLeading : .top
            case .topTrailing:
                return isIpad ? .topTrailing : .top
            case .bottomCenter:
                return .bottom
            case .bottomLeading:
                return isIpad ? .bottomLeading : .bottom
            case .bottomTrailing:
                return isIpad ? .bottomTrailing : .bottom
            }
        }

        var isTop: Bool {
            switch self {
            case .topCenter, .topLeading, .topTrailing:
                return true
            case .bottomCenter, .bottomLeading, .bottomTrailing:
                return false
            }
        }
    }

    @Published var currentToast: Alert?

    func showToast(
        for duration: TimeInterval = 4.0,
        animationDuration: TimeInterval = 0.25,
        in location: AlertLocation = .topCenter,
        config: AlertConfig,
        content: AlertContent,
        attributes: AlertAttributes? = nil
    ) {
        let defaultHandler = content.dismiss?.onPress
        var contentWithDismisser = content
        contentWithDismisser.updateDismissHandler {
            self.dismissToast()

            defaultHandler?()
        }

        currentToast = Alert(
            config: config,
            content: contentWithDismisser,
            attributes: attributes,
            duration: duration,
            animationDuration: animationDuration,
            location: location
        )
    }

    func showErrorToast(
        title: String = "Error",
        userFacingMessage: String,
        underlyingError: ParraError
    ) {
        let style = AlertConfig.Style.error

        showToast(
            config: AlertConfig(
                style: style
            ),
            content: AlertContent(
                title: LabelContent(text: title),
                subtitle: LabelContent(text: userFacingMessage),
                icon: AlertContent.defaultIcon(for: style),
                dismiss: AlertContent.defaultDismiss(for: style)
            )
        )
    }

    func dismissToast() {
        currentToast = nil
    }
}
