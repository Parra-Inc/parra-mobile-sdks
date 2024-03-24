//
//  LatestVersionManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// What is the version token and is it different than just the version string?
// Store

final actor LatestVersionManager {
    // MARK: - Lifecycle

    init(networkManager: ParraNetworkManager) {
        self.networkManager = networkManager
    }

    // MARK: - Internal

    enum Constant {
        static let defaultsKey = "app_version_info"
        static let currentVersionKey = "current_version"
    }

    struct VersionInfo: Codable {
        let version: String
        let build: String
    }

//    init() {
//    }

    func latestVersionToken() async -> String? {
        guard let cached = await versionCache.read(
            name: Constant.currentVersionKey
        ) else {
            return nil
        }

        cached.version

        // https://itunes.apple.com/lookup?bundleId=com.baronapp.cameo&date=1711118565073
        //     return `itms-apps://apps.apple.com/${countryCode}app/id${opt.appID}`;

//        await networkManager.performExternalRequest(
//            to: URL(string: "https://itunes.apple.com/lookup")!,
//            queryItems: [
//                "bundleId": "",
//                "date": "" //seconds since epoch
//            ],
//            cachePolicy: .reloadRevalidatingCacheData
//        )

        return nil
    }

    func updateLatestSeenVersionToken(_ versionToken: String) {
//        versionCache.write(name: <#T##String#>, value: <#T##Version?#>)
    }

    func should() {}

    // MARK: - Private

    private let networkManager: ParraNetworkManager
    private let versionCache = ParraStorageModule<VersionInfo>(
        dataStorageMedium: .userDefaults(key: Constant.defaultsKey),
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )
}

/**

 - [ ]  for automatic presentations:
 1. cached app version string was previously set and has changed
 2. HTTP request to apple API shows that the app version is not the latest
 */
