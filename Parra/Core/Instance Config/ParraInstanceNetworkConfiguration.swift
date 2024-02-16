//
//  ParraInstanceNetworkConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraInstanceNetworkConfiguration {
    let urlSession: URLSessionType
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
}
