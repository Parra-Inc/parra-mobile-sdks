//
//  ParraAttributeProvider.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/27/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol ParraAttributes: Codable {}

internal protocol ParraAttributeProvider {
    static func getAttributes() async -> ParraAttributes
}
