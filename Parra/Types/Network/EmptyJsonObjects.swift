//
//  EmptyJsonObjects.swift
//  Parra
//
//  Created by Mick MacCallum on 7/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal let EmptyJsonObjectData = "{}".data(using: .utf8)!

internal struct EmptyRequestObject: Codable {}
internal struct EmptyResponseObject: Codable {}
