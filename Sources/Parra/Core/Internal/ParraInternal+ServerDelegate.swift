//
//  ParraInternal+ServerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal: ServerDelegate {
    func server(
        _ server: any Server,
        didReceiveResponse response: HTTPURLResponse,
        for request: URLRequest
    ) {
        logEvent(
            .httpRequest(
                request: request,
                response: response
            )
        )
    }
}
