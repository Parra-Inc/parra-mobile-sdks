//
//  SyncManagerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol SyncManagerDelegate: AnyObject {
    func getSyncTargets() -> [SyncTarget]
}
