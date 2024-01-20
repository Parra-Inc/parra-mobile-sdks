//
//  ParraNetworkManagerUrlSessionDelegateProxy.swift
//  Parra
//
//  Created by Mick MacCallum on 7/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal class ParraNetworkManagerUrlSessionDelegateProxy: NSObject, URLSessionTaskDelegate {

    weak private var delegate: ParraUrlSessionDelegate?

    init(delegate: ParraUrlSessionDelegate) {
        self.delegate = delegate
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        Task {
            await delegate?.urlSession(
                session,
                task: task,
                didFinishCollecting: metrics
            )
        }
    }
}
