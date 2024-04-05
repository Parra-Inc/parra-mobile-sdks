//
//  MockParraNetworkManager.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

struct MockParraNetworkManager {
    let networkManager: ParraNetworkManager
    let dataManager: ParraDataManager
    let urlSession: MockURLSession
    let appState: ParraAppState
}
