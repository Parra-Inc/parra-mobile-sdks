//
//  LatestVersionManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

// TODO: Disable in SwiftUI previews?

// What is the version token and is it different than just the version string?
// Store

// If automatic or delayed, on app launch
// 1. Apple API, fetch latest version
// 2. If cached apple version != nil and != new version from api
// 3. Cache apple version
// 4. hit GET app-info
// 5. If app info has release, present modal with or without delay
// 6. Cache version token from app info
//
// If manual, support fetch and auto present, or fetch and manual present
// 1. Fetch should hit GET app-info
// 2. Cache token
// 3. If auto present, auto present

private let logger = Logger()

final actor LatestVersionManager {
    // MARK: - Lifecycle

    init(
        configuration: ParraConfiguration,
        networkManager: ParraNetworkManager
    ) {
        self.configuration = configuration
        self.networkManager = networkManager
    }

    // MARK: - Internal

    enum Constant {
        static let appVersionKey = "app_version_info"
        static let versionTokenKey = "version_token_info"

        static let currentVersionKey = "current_version"
    }

    struct AppVersionInfo: Codable {
        let version: String
        let versionShort: String
        let date: Date
    }

    struct VersionTokenInfo: Codable {
        let token: String
        let date: Date
    }

    func fetchAndPresentWhatsNew(
        with options: ParraWhatsNewOptions,
        using modalScreenManager: ModalScreenManager
    ) async {
        if options.presentationMode == .manual {
            logger.debug(
                "ParraWhatsNewOptions.presentationMode is manual. Skipping check for new app versions."
            )

            return
        }

        do {
            guard
                let bundleIdentifier = ParraInternal.appBundleIdentifier() else {
                throw ParraError.message("Could not load bundle id for app")
            }

            guard
                let bundleVersion = ParraInternal.appBundleVersion(),
                let bundleVersionShort = ParraInternal.appBundleVersionShort() else {
                throw ParraError.message("Could not load app version for app")
            }

            let currentAppVersion = await cachedAppVersion()
            let current = currentAppVersion?.version

            // Cache the current app version since we've launched once without
            // it being set. This will allow the next launch to proceed further.
            try await updateLatestAppVersion(
                bundleVersion,
                versionShort: bundleVersionShort
            )

            // 1. If there is no cached app version it indicates the first time
            // the app is launched. Don't check for updates.
            if current == nil {
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
            if current == nextRelease.version {
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
            #if !DEBUG
            try await updateLatestSeenVersionToken(latestAppInfo.versionToken)
            #endif

            let contentObserver = ReleaseContentObserver(
                initialParams: ReleaseContentObserver.InitialParams(
                    contentType: .newInstalledVersion(newInstalledVersionInfo),
                    networkManager: networkManager
                )
            )

            try await Task.sleep(for: options.presentationMode.delay)

            modalScreenManager.presentModalView(
                of: ReleaseWidget.self,
                with: .default,
                localBuilder: .init(),
                contentObserver: contentObserver,
                onDismiss: nil
            )
        } catch {
            logger.error("Fetch and present what's new error", error)
        }
    }

    func fetchLatestAppInfo() async throws -> AppInfo {
        let versionToken = await cachedVersionToken()

        let response = try await networkManager.getAppInfo(
            versionToken: versionToken?.token
        )

        let newVersionToken = response.versionToken

        // Only update the token if it changed, since updating will bump the
        // updated date field on the version info.
        if let versionToken, versionToken.token != newVersionToken {
            try await updateLatestSeenVersionToken(response.versionToken)
        }

        return response
    }

    func fetchLatestAppStoreUpdate(
        for bundleId: String,
        since: Date = .distantPast
    ) async throws -> AppStoreResponse.Result? {
        let regionCode = Locale.current.region?.identifier.lowercased() ?? "us"

        let response: AppStoreResponse = try await networkManager
            .performExternalRequest(
                to: URL(
                    string: "https://itunes.apple.com/\(regionCode)/lookup"
                )!,
                queryItems: [
                    "bundleId": bundleId,
                    "date": "\(since.timeIntervalSince1970)"
                ],
                cachePolicy: .reloadRevalidatingCacheData
            )

        #if DEBUG
        return LatestVersionManager.AppStoreResponse.validStates().first?
            .results.first
        #else
        return response.results.first
        #endif
    }

    // MARK: - Private

    private let networkManager: ParraNetworkManager
    private let configuration: ParraConfiguration

    private let appVersionCache = ParraStorageModule<AppVersionInfo>(
        dataStorageMedium: .userDefaults(key: Constant.appVersionKey),
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )

    private let versionTokenCache = ParraStorageModule<VersionTokenInfo>(
        dataStorageMedium: .userDefaults(key: Constant.versionTokenKey),
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )

    private func cachedAppVersion() async -> AppVersionInfo? {
        guard let cached = await appVersionCache.read(
            name: Constant.currentVersionKey
        ) else {
            return nil
        }

        return cached
    }

    private func cachedVersionToken() async -> VersionTokenInfo? {
        guard let cached = await versionTokenCache.read(
            name: Constant.currentVersionKey
        ) else {
            return nil
        }

        return cached
    }

    private func updateLatestAppVersion(
        _ version: String,
        versionShort: String
    ) async throws {
        try await appVersionCache.write(
            name: Constant.currentVersionKey,
            value: AppVersionInfo(
                version: version,
                versionShort: versionShort,
                date: .now
            )
        )
    }

    private func updateLatestSeenVersionToken(_ token: String) async throws {
        try await versionTokenCache.write(
            name: Constant.currentVersionKey,
            value: VersionTokenInfo(
                token: token,
                date: .now
            )
        )
    }
}
