//
//  Syncable.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/28/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public protocol Syncable {
    func hasDataToSync() async -> Bool
    func synchronizeData() async
}
