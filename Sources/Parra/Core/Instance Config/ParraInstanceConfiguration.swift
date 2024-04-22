//
//  ParraInstanceConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
    static let apiConfiguration: URLSessionConfiguration = {
        let diskCacheUrl = DataManager.Path.networkCachesDirectory

        // Cache may reject image entries if they are greater than 10% of the
        // cache's size so these need to reflect that.
        let networkCache = URLCache(
            memoryCapacity: 50 * 1_024 * 1_024,
            diskCapacity: 300 * 1_024 * 1_024,
            directory: diskCacheUrl
        )

        let configuration = URLSessionConfiguration.default

        configuration.urlCache = networkCache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = 15.0
        configuration.timeoutIntervalForResource = 30.0
        configuration.waitsForConnectivity = true

        return configuration
    }()

    static let authConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default

        configuration
            .requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.timeoutIntervalForRequest = 10.0
        // Setting this to a lower value because it appears that form POSTs
        // fall into this category and we need auth endpoints to fail quickly.
        configuration.timeoutIntervalForResource = 10.0
        configuration.waitsForConnectivity = true

        return configuration
    }()

    static let externalConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default

        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        configuration.timeoutIntervalForRequest = 20.0
        configuration.timeoutIntervalForResource = 30.0
        configuration.waitsForConnectivity = true

        return configuration
    }()
}

struct ParraInstanceConfiguration {
    static let `default`: ParraInstanceConfiguration = {
        let baseStorageUrl = DataManager.Path.parraDirectory
        let storageDirectoryName = DataManager.Directory
            .storageDirectoryName

        return ParraInstanceConfiguration(
            apiServerConfiguration: ServerConfiguration(
                urlSession: URLSession(configuration: .apiConfiguration),
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            ),
            authServerConfiguration: ServerConfiguration(
                urlSession: URLSession(configuration: .authConfiguration),
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            ),
            externalServerConfiguration: ServerConfiguration(
                urlSession: URLSession(configuration: .externalConfiguration),
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            ),
            storageConfiguration: ParraInstanceStorageConfiguration(
                baseDirectory: baseStorageUrl,
                storageDirectoryName: storageDirectoryName,
                sessionJsonEncoder: .parraEncoder,
                sessionJsonDecoder: .parraDecoder,
                eventJsonEncoder: .spaceOptimizedEncoder,
                eventJsonDecoder: .spaceOptimizedDecoder
            )
        )
    }()

    let apiServerConfiguration: ServerConfiguration
    let authServerConfiguration: ServerConfiguration
    let externalServerConfiguration: ServerConfiguration
    let storageConfiguration: ParraInstanceStorageConfiguration
}
