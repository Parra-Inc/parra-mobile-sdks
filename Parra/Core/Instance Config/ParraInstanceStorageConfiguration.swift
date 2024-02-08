//
//  ParraInstanceStorageConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraInstanceStorageConfiguration {
    let baseDirectory: URL
    let storageDirectoryName: String
    let sessionJsonEncoder: JSONEncoder
    let sessionJsonDecoder: JSONDecoder
    let eventJsonEncoder: JSONEncoder
    let eventJsonDecoder: JSONDecoder
}
