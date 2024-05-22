//
//  AppInfoManager+presentationFlows.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

extension AppInfoManager {
    /// Noop
    func handleDebugWhatsNewFlow() {
        logger.debug(
            "Skipping What's New check in DEBUG mode."
        )
    }

    /// Skips App Store API checks and uses the bundle short version instead of
    /// the bundle version to determine if a new version has been installed.
    func handleBetaWhatsNewFlow(
        style: ParraReleaseOptions.PresentationStyle,
        after delay: TimeInterval
    ) async throws {
        guard
            let bundleVersion = ParraInternal.appBundleVersion(),
            let bundleVersionShort = ParraInternal.appBundleVersionShort() else {
            throw ParraError.message("Could not load app version for app")
        }

        let currentAppVersion = await cachedAppVersion()
        // The internal build/longform version string.
        let currentBuild = currentAppVersion?.version

        // Cache the current app version since we've launched once without
        // it being set. This will allow the next launch to proceed further.
        try await updateLatestAppVersion(
            bundleVersion,
            versionShort: bundleVersionShort
        )

        guard currentBuild != bundleVersionShort else {
            logger.debug(
                "Bundle short version is the same as the cached version. Skipping What's New flow.",
                [
                    "bundleVersion": bundleVersion,
                    "bundleVersionShort": bundleVersionShort
                ]
            )

            return
        }

        let latestAppInfo = try await fetchLatestAppInfo()

        try await displayReleaseIfExists(
            latestAppInfo: latestAppInfo,
            with: style,
            after: delay
        )
    }

    /// Follows the full flow of checking cached app version, App Store API
    /// and new releases from Parra API.
    func handleProductionWhatsNewFlow(
        style: ParraReleaseOptions.PresentationStyle,
        after delay: TimeInterval
    ) async throws {
        guard
            let bundleIdentifier = ParraInternal.appBundleIdentifier() else
        {
            throw ParraError.message("Could not load bundle id for app")
        }

        guard
            let bundleVersion = ParraInternal.appBundleVersion(),
            let bundleVersionShort = ParraInternal.appBundleVersionShort() else {
            throw ParraError.message("Could not load app version for app")
        }

        let currentAppVersion = await cachedAppVersion()
        // The user-facing version string
        let currentVersion = currentAppVersion?.versionShort

        // Cache the current app version since we've launched once without
        // it being set. This will allow the next launch to proceed further.
        try await updateLatestAppVersion(
            bundleVersion,
            versionShort: bundleVersionShort
        )

        // 1. If there is no cached app version it indicates the first time
        // the app is launched. Don't check for updates.
        if currentVersion == nil {
            logger.debug(
                "App is being launch for first time after install. Skipping update check."
            )

            return
        }

        let since = currentAppVersion?.date ?? .distantPast
        guard let nextRelease = try await fetchLatestAppStoreUpdate(
            for: bundleIdentifier,
            since: since
        ) else {
            logger.debug(
                "App Store API did not indicate new version is available."
            )

            return
        }

        // 2. If there is a cached app version, but it's the same as the
        // version from the App Store, don't check for updates.
        if currentVersion == nextRelease.version {
            logger.debug(
                "Current app version is same as latest on the App Store. Skipping update check."
            )

            return
        }

        let latestAppInfo = try await fetchLatestAppInfo()
        let currentVersionInfo = await cachedVersionToken()

        guard latestAppInfo.versionToken != currentVersionInfo?.token else {
            logger.debug(
                "Version token has not changed in fetched release."
            )

            return
        }

        try await displayReleaseIfExists(
            latestAppInfo: latestAppInfo,
            with: style,
            after: delay
        )
    }

    func handleWhatsNewFlow(
        in appInfo: AppInfo,
        with behavior: ParraReleaseOptions.Behavior,
        style: ParraReleaseOptions.PresentationStyle,
        after delay: TimeInterval = 0.0
    ) async throws {
        switch behavior {
        case .production:
            try await handleProductionWhatsNewFlow(
                style: style,
                after: delay
            )
        case .beta:
            try await handleBetaWhatsNewFlow(
                style: style,
                after: delay
            )
        case .debug:
            handleDebugWhatsNewFlow()
        }
    }

    private func displayReleaseIfExists(
        latestAppInfo: AppInfo,
        with style: ParraReleaseOptions.PresentationStyle,
        after delay: TimeInterval
    ) async throws {
        guard let newInstalledVersionInfo = latestAppInfo
            .newInstalledVersionInfo else
        {
            logger.debug(
                "No new version info available."
            )

            return
        }

        // Found a new version token, so cache it so we don't present the
        // what's new screen twice for the same release.
        try await updateLatestSeenVersionToken(latestAppInfo.versionToken)

        let contentObserver = ReleaseContentObserver(
            initialParams: ReleaseContentObserver.InitialParams(
                contentType: .newInstalledVersion(newInstalledVersionInfo),
                api: api
            )
        )

        try await Task.sleep(for: delay)

        Task { @MainActor in
            let displayModal = {
                self.modalScreenManager.presentModalView(
                    of: ReleaseWidget.self,
                    with: .default,
                    contentObserver: contentObserver,
                    onDismiss: nil
                )
            }

            switch style {
            case .toast:
                alertManager.showWhatsNewToast(
                    for: newInstalledVersionInfo,
                    primaryAction: displayModal
                )
            case .modal:
                displayModal()
            }
        }
    }
}
