//
//  ParraSessionEventSyncPriority.swift
//  Parra
//
//  Created by Mick MacCallum on 9/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraSessionEventSyncPriority: Codable {
    case low
    case high
    case critical
}
