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

public extension ParraAlertManager {
    @MainActor
    struct Toast: Equatable {
        public let level: ParraAlertLevel
        public let content: ParraAlertContent
        public let attributes: ParraAttributes.ToastAlert?
        public let onDismiss: () -> Void

        public let duration: TimeInterval
        public let animationDuration: TimeInterval
        public let location: ToastLocation

        public let primaryAction: (() -> Void)?

        public nonisolated static func == (
            lhs: ParraAlertManager.Toast,
            rhs: ParraAlertManager.Toast
        ) -> Bool {
            return lhs.content == rhs.content
        }
    }

    /// Where the alert/toast should be presented on screen. Note that leading
    /// and trailing alignments are only applicable to iPad. On iPhone all the
    /// top alignments resolve to `topCenter` and all bottom alignments resolve
    /// to `bottomCenter`.
    @MainActor
    enum ToastLocation {
        case topCenter
        case topLeading
        case topTrailing
        case bottomCenter
        case bottomLeading
        case bottomTrailing

        // MARK: - Public

        public var toViewAlignment: Alignment {
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

        public var isTop: Bool {
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
        level: ParraAlertLevel,
        content: ParraAlertContent,
        attributes: ParraAttributes.ToastAlert? = nil,
        primaryAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        currentToast = Toast(
            level: level,
            content: content,
            attributes: attributes,
            onDismiss: {
                self.dismissToast()

                onDismiss?()
            },
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
        primaryAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let level = ParraAlertLevel.success

        showToast(
            for: duration,
            animationDuration: animationDuration,
            in: location,
            level: level,
            content: ParraAlertContent(
                title: ParraLabelContent(text: title),
                subtitle: ParraLabelContent(text: subtitle),
                icon: ParraAlertContent.defaultIcon(for: level),
                dismiss: ParraAlertContent.defaultDismiss(for: level)
            ),
            primaryAction: primaryAction,
            onDismiss: onDismiss
        )
    }

    func showErrorToast(
        title: String = "Error",
        userFacingMessage: String,
        underlyingError: ParraError,
        in location: ToastLocation = .topCenter,
        for duration: TimeInterval = 4.0,
        animationDuration: TimeInterval = 0.25,
        primaryAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let level = ParraAlertLevel.error

        showToast(
            for: duration,
            animationDuration: animationDuration,
            in: location,
            level: level,
            content: ParraAlertContent(
                title: ParraLabelContent(text: title),
                subtitle: ParraLabelContent(text: userFacingMessage),
                icon: ParraAlertContent.defaultIcon(for: level),
                dismiss: ParraAlertContent.defaultDismiss(for: level)
            ),
            primaryAction: primaryAction,
            onDismiss: onDismiss
        )
    }

    internal func showWhatsNewToast(
        for newInstalledVersionInfo: ParraNewInstalledVersionInfo,
        in location: ToastLocation = .bottomCenter,
        for duration: TimeInterval = 8.0,
        animationDuration: TimeInterval = 0.25,
        primaryAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let level = ParraAlertLevel.info

        showToast(
            for: duration,
            in: location,
            level: level,
            content: ParraAlertContent(
                title: ParraLabelContent(
                    text: "New Version Available!"
                ),
                subtitle: ParraLabelContent(
                    text: "Version \(newInstalledVersionInfo.release.version) is now available."
                ),
                icon: ParraAlertContent.defaultIcon(for: level),
                dismiss: ParraAlertContent.defaultDismiss(for: level)
            ),
            attributes: ParraAttributes.ToastAlert(),
            primaryAction: primaryAction,
            onDismiss: onDismiss
        )
    }

    func dismissToast() {
        currentToast = nil
    }
}
