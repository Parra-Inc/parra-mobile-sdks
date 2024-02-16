//
//  ParraNetworkManagerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol ParraNetworkManagerDelegate: AnyObject {
    func networkManager(
        _ networkManager: ParraNetworkManager,
        didReceiveResponse response: HTTPURLResponse,
        for request: URLRequest
    )
}
