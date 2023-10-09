//
//  ParraInstanceNetworkConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraInstanceNetworkConfiguration {
    internal let urlSession: URLSession
    internal let jsonEncoder: JSONEncoder
    internal let jsonDecoder: JSONDecoder
}
