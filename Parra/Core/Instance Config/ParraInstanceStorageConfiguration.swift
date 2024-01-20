//
//  ParraInstanceStorageConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraInstanceStorageConfiguration {
    internal let baseDirectory: URL
    internal let storageDirectoryName: String
    internal let sessionJsonEncoder: JSONEncoder
    internal let sessionJsonDecoder: JSONDecoder
    internal let eventJsonEncoder: JSONEncoder
    internal let eventJsonDecoder: JSONDecoder
}
