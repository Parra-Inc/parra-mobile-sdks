//
//  ParraNetworkManagerUrlSessionDelegateProxy.swift
//  Parra
//
//  Created by Mick MacCallum on 7/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

class ParraNetworkManagerUrlSessionDelegateProxy: NSObject,
    URLSessionTaskDelegate
{
    // MARK: Lifecycle

    init(delegate: ParraUrlSessionDelegate) {
        self.delegate = delegate
    }

    // MARK: Internal

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

    // MARK: Private

    private weak var delegate: ParraUrlSessionDelegate?
}
