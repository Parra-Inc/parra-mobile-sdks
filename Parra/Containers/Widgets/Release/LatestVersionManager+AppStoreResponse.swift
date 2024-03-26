//
//  LatestVersionManager+AppStoreResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension LatestVersionManager {
    struct AppStoreResponse: Codable {
        // MARK: - Lifecycle

        init(
            results: [Result],
            resultCount: Int
        ) {
            self.results = results
            self.resultCount = resultCount
        }

        // MARK: - Internal

        // TODO: Could probably do something with unused fields:
        // supportedDevices, artwork, screenshots

        struct Result: Codable {
            // MARK: - Lifecycle

            init(
                //                currency: String,
//                minimumOsVersion: String,
                description: String,
//                sellerName: String,
                bundleId: String,
                trackName: String,
//                releaseDate: Date,
                currentVersionReleaseDate: Date,
                releaseNotes: String,
//                averageUserRating: Double,
//                averageUserRatingForCurrentVersion: Double,
//                userRatingCount: Int,
//                fileSizeBytes: Int,
//                formattedPrice: String,
//                price: Double,
                version: String
            ) {
//                self.currency = currency
//                self.minimumOsVersion = minimumOsVersion
                self.description = description
//                self.sellerName = sellerName
                self.bundleId = bundleId
                self.trackName = trackName
//                self.releaseDate = releaseDate
                self.currentVersionReleaseDate = currentVersionReleaseDate
                self.releaseNotes = releaseNotes
//                self.averageUserRating = averageUserRating
//                self.averageUserRatingForCurrentVersion = averageUserRatingForCurrentVersion
//                self.userRatingCount = userRatingCount
//                self.fileSizeBytes = fileSizeBytes
//                self.formattedPrice = formattedPrice
//                self.price = price
                self.version = version
            }

            // MARK: - Internal

//            let currency: String
//            let minimumOsVersion: String
            let description: String
//            let sellerName: String
            let bundleId: String

            /// The app name
            let trackName: String

            /// The initial release of the app
//            let releaseDate: Date

            /// The release of the update
            let currentVersionReleaseDate: Date
            let releaseNotes: String

//            let averageUserRating: Double
//            let averageUserRatingForCurrentVersion: Double
//            let userRatingCount: Int

//            let fileSizeBytes: Int
//            let formattedPrice: String
//            let price: Double

            /// The actual version string (1.0.0)
            let version: String
        }

        let results: [Result]
        let resultCount: Int
    }
}
