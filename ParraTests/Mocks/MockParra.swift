//
//  MockParra.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

struct MockParra {
    let parra: Parra
    let mockNetworkManager: MockParraNetworkManager
    let tenantId: String
    let applicationId: String
}
