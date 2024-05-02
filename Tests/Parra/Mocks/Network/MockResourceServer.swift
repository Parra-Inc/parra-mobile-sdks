//
//  MockResourceServer.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

struct MockResourceServer<S> where S: Server {
    let resourceServer: S
    let dataManager: DataManager
    let urlSession: MockURLSession
    let appState: ParraAppState
}
