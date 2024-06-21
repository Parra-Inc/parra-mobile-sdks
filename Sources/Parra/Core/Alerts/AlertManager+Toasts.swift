//
//  AlertManager+Toasts.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

extension AlertManager {
    struct Toast: Equatable {
        let level: AlertLevel
        let content: ParraAlertContent
        let attributes: ParraAttributes.ToastAlert?
        let onDismiss: () -> Void

        let duration: TimeInterval
        let animationDuration: TimeInterval
        let location: ToastLocation

        let primaryAction: (() -> Void)?

        static func == (
            lhs: AlertManager.Toast,
            rhs: AlertManager.Toast
        ) -> Bool {
            return lhs.content == rhs.content
        }
    }

    /// Where the alert/toast should be presented on screen. Note that leading
    /// and trailing alignments are only applicable to iPad. On iPhone all the
    /// top alignments resolve to `topCenter` and all bottom alignments resolve
    /// to `bottomCenter`.
    enum ToastLocation {
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

    func showToast(
        for duration: TimeInterval = 4.0,
        animationDuration: TimeInterval = 0.25,
        in location: ToastLocation = .topCenter,
        level: AlertLevel,
        content: ParraAlertContent,
        attributes: ParraAttributes.ToastAlert? = nil,
        primaryAction: (() -> Void)? = nil
    ) {
        currentToast = Toast(
            level: level,
            content: content,
            attributes: attributes,
            onDismiss: dismissToast,
            duration: duration,
            animationDuration: animationDuration,
            location: location,
            primaryAction: primaryAction
        )
    }

    func showSuccessToast(
        title: String = "Success!",
        subtitle: String,
        in location: ToastLocation = .topCenter,
        for duration: TimeInterval = 4.0,
        animationDuration: TimeInterval = 0.25,
        primaryAction: (() -> Void)? = nil
    ) {
        let level = AlertLevel.success

        showToast(
            for: duration,
            animationDuration: animationDuration,
            in: location,
            level: level,
            content: ParraAlertContent(
                title: LabelContent(text: title),
                subtitle: LabelContent(text: subtitle),
                icon: ParraAlertContent.defaultIcon(for: level),
                dismiss: ParraAlertContent.defaultDismiss(for: level)
            ),
            primaryAction: primaryAction
        )
    }

    func showErrorToast(
        title: String = "Error",
        userFacingMessage: String,
        underlyingError: ParraError,
        in location: ToastLocation = .topCenter,
        for duration: TimeInterval = 4.0,
        animationDuration: TimeInterval = 0.25,
        primaryAction: (() -> Void)? = nil
    ) {
        let level = AlertLevel.error

        showToast(
            for: duration,
            animationDuration: animationDuration,
            in: location,
            level: level,
            content: ParraAlertContent(
                title: LabelContent(text: title),
                subtitle: LabelContent(text: userFacingMessage),
                icon: ParraAlertContent.defaultIcon(for: level),
                dismiss: ParraAlertContent.defaultDismiss(for: level)
            ),
            primaryAction: primaryAction
        )
    }

    func showWhatsNewToast(
        for newInstalledVersionInfo: NewInstalledVersionInfo,
        in location: ToastLocation = .bottomCenter,
        for duration: TimeInterval = 8.0,
        animationDuration: TimeInterval = 0.25,
        primaryAction: (() -> Void)? = nil
    ) {
        let level = AlertLevel.info

        showToast(
            for: duration,
            in: location,
            level: level,
            content: ParraAlertContent(
                title: LabelContent(
                    text: "New Version Available!"
                ),
                subtitle: LabelContent(
                    text: "Version \(newInstalledVersionInfo.release.version) is now available."
                ),
                icon: ParraAlertContent.defaultIcon(for: level),
                dismiss: ParraAlertContent.defaultDismiss(for: level)
            ),
            attributes: ParraAttributes.ToastAlert(),
            primaryAction: primaryAction
        )
    }

    func dismissToast() {
        currentToast = nil
    }
}
