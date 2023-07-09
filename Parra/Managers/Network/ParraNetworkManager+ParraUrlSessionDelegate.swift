//
//  ParraNetworkManager+ParraUrlSessionDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 7/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraNetworkManager: ParraUrlSessionDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) async {
        Logger.debug(
            "Finished collecting metrics for task: \(task.taskIdentifier)",
            [
                "redirectCount": metrics.redirectCount,
                "taskInterval": [
                    "duration": String(
                        format: "%0.3f", metrics.taskInterval.duration
                    ),
                    "unit": "seconds"
                ]
                // TODO: Figure out which transaction metrics we'd like to collect.
                //                "transactionMetrics": metrics.transactionMetrics
            ]
        )
    }
}
