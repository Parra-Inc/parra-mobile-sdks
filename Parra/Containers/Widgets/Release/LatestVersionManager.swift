//
//  LatestVersionManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

private let logger = Logger()

final actor LatestVersionManager {
    // MARK: - Lifecycle

    init(
        configuration: ParraConfiguration,
        modalScreenManager: ModalScreenManager,
        alertManager: AlertManager,
        networkManager: ParraNetworkManager
    ) {
        self.configuration = configuration
        self.modalScreenManager = modalScreenManager
        self.alertManager = alertManager
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

    let networkManager: ParraNetworkManager
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

    func fetchAndPresentWhatsNew(
        with options: ParraReleaseOptions,
        using modalScreenManager: ModalScreenManager
    ) async {
        do {
            switch options.presentationMode {
            case .automatic(let behavior):
                try await handleWhatsNewFlow(
                    with: behavior,
                    style: options.presentationStyle
                )
            case .delayed(let behavior, let delay):
                try await handleWhatsNewFlow(
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
}
