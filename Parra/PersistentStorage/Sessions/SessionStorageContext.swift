//
//  SessionStorageContext.swift
//  Parra
//
//  Created by Mick MacCallum on 8/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct SessionStorageContext {
    let session: ParraSession
    let sessionPath: URL
    let eventsPath: URL
}
