//
//  ParraInstanceConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraInstanceConfiguration {
    static let `default`: ParraInstanceConfiguration = {
        let diskCacheUrl = ParraDataManager.Path.networkCachesDirectory
        let baseStorageUrl = ParraDataManager.Path.parraDirectory
        let storageDirectoryName = ParraDataManager.Directory
            .storageDirectoryName

        // Cache may reject image entries if they are greater than 10% of the cache's size
        // so these need to reflect that.
        let networkCache = URLCache(
            memoryCapacity: 50 * 1_024 * 1_024,
            diskCapacity: 300 * 1_024 * 1_024,
            directory: diskCacheUrl
        )

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = networkCache
        sessionConfig.requestCachePolicy = .returnCacheDataElseLoad

        let urlSession = URLSession(configuration: sessionConfig)

        return ParraInstanceConfiguration(
            serverConfiguration: ServerConfiguration(
                urlSession: urlSession,
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

    let serverConfiguration: ServerConfiguration
    let storageConfiguration: ParraInstanceStorageConfiguration
}
