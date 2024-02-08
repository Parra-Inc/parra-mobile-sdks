//
//  SessionStorageContext.swift
//  Parra
//
//  Created by Mick MacCallum on 8/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct SessionStorageContext: Equatable {
    private(set) var session: ParraSession
    let sessionPath: URL
    let eventsPath: URL

    mutating func updateSession(to newSession: ParraSession) {
        session = newSession
    }
}
