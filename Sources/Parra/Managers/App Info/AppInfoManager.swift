//
//  AppInfoManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

private let logger = Logger()

final class AppInfoManager {
    // MARK: - Lifecycle

    init(
        configuration: ParraConfiguration,
        modalScreenManager: ModalScreenManager,
        alertManager: AlertManager,
        api: API,
        authServer: AuthServer,
        externalResourceServer: ExternalResourceServer
    ) {
        self.configuration = configuration
        self.modalScreenManager = modalScreenManager
        self.alertManager = alertManager
        self.api = api
        self.authServer = authServer
        self.externalResourceServer = externalResourceServer
    }

    // MARK: - Internal

    enum Constant {
        static let appVersionKey = "app_version_info"
        static let versionTokenKey = "version_token_info"

        static let currentVersionKey = "current_version"
        static let appInfoCacheKey = "app_info_cache"
        static let fullAppInfoKey = "full_app_info"
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

    let api: API
    let authServer: AuthServer
    let externalResourceServer: ExternalResourceServer
    let modalScreenManager: ModalScreenManager
    let alertManager: AlertManager
    let configuration: ParraConfiguration

    let appVersionCache = ParraStorageModule<AppVersionInfo>(
        dataStorageMedium: .userDefaults(key: Constant.appVersionKey),
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )

    let versionTokenCache = ParraStorageModule<VersionTokenInfo>(
        dataStorageMedium: .userDefaults(key: Constant.versionTokenKey),
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )

    let appInfoCache = ParraStorageModule<ParraAppInfo>(
        dataStorageMedium: .userDefaults(key: Constant.appInfoCacheKey),
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )

    func checkAndPresentWhatsNew(
        against appInfo: ParraAppInfo,
        with options: ParraReleaseOptions,
        using modalScreenManager: ModalScreenManager
    ) async {
        do {
            switch options.presentationMode {
            case .automatic(let behavior):
                try await handleWhatsNewFlow(
                    in: appInfo,
                    with: behavior,
                    style: options.presentationStyle
                )
            case .delayed(let behavior, let delay):
                try await handleWhatsNewFlow(
                    in: appInfo,
                    with: behavior,
                    style: options.presentationStyle,
                    after: delay
                )
            case .manual:
                logger.debug(
                    "ParraWhatsNewOptions.presentationMode is manual. Skipping check for new app versions."
                )

                return
            }

            logger.info("Finished fetching and presenting What's New.")
        } catch {
            logger.error("Fetch and present what's new error", error)
        }
    }

    /// - Parameter force: Don't send the last version token with the request,
    ///                    meaning the latest release will always be fetched.
    func fetchLatestAppInfo(
        force: Bool = false,
        timeout: TimeInterval? = nil
    ) async throws -> ParraAppInfo {
        let versionToken: String? = if force {
            nil
        } else {
            await cachedVersionToken()?.token
        }

        let appInfo: ParraAppInfo

        do {
            appInfo = try await authServer.getAppInfo(
                versionToken: versionToken,
                timeout: timeout
            )
        } catch {
            logger.error("Error fetching latest app info", error)

            if let cached = await cachedAppInfo() {
                logger.debug("Falling back on cached app info.")

                appInfo = cached
            } else {
                logger.debug("No cached app info existed to fall back on.")

                throw error
            }
        }

        // Persist a copy of the entire app info response.
        try await updateCachedAppInfo(appInfo)

        // Only update the token if it changed, since updating will bump the
        // updated date field on the version info.
        if let versionToken,
           let newVersionToken = appInfo.versionToken,
           versionToken != newVersionToken
        {
            try await updateLatestSeenVersionToken(newVersionToken)
        }

        return appInfo
    }

    func fetchLatestAppStoreUpdate(
        for bundleId: String,
        since: Date = .distantPast
    ) async throws -> AppStoreResponse.Result? {
        let regionCode = Locale.current.region?.identifier.lowercased() ?? "us"

        let response: AppStoreResponse = try await externalResourceServer
            .performRequest(
                to: URL(
                    string: "https://itunes.apple.com/\(regionCode)/lookup"
                )!,
                queryItems: [
                    "bundleId": bundleId,
                    "date": "\(since.timeIntervalSince1970)"
                ],
                cachePolicy: .reloadRevalidatingCacheData
            )

        return response.results.first
    }

    func cachedAppVersion() async -> AppVersionInfo? {
        guard let cached = await appVersionCache.read(
            name: Constant.currentVersionKey
        ) else {
            return nil
        }

        return cached
    }

    func cachedVersionToken() async -> VersionTokenInfo? {
        guard let cached = await versionTokenCache.read(
            name: Constant.currentVersionKey
        ) else {
            return nil
        }

        return cached
    }

    func cachedAppInfo() async -> ParraAppInfo? {
        guard let cached = await appInfoCache.read(
            name: Constant.fullAppInfoKey
        ) else {
            return nil
        }

        return cached
    }

    func updateLatestAppVersion(
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

    func updateLatestSeenVersionToken(_ token: String) async throws {
        try await versionTokenCache.write(
            name: Constant.currentVersionKey,
            value: VersionTokenInfo(
                token: token,
                date: .now
            )
        )
    }

    func updateCachedAppInfo(_ appInfo: ParraAppInfo) async throws {
        try await appInfoCache.write(
            name: Constant.fullAppInfoKey,
            value: appInfo
        )
    }
}
