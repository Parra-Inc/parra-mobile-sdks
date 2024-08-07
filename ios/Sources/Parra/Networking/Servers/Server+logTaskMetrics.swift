//
//  Server+logTaskMetrics.swift
//  Parra
//
//  Created by Mick MacCallum on 6/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Server {
    func logMetrics(
        _ metrics: URLSessionTaskMetrics,
        for task: URLSessionTask
    ) {
        Logger.debug(
            "Finished collecting metrics for task: \(task.taskIdentifier)",
            [
                "redirectCount": metrics.redirectCount,
                "taskInterval": [
                    "duration": String(
                        format: "%0.3f", metrics.taskInterval.duration
                    ),
                    "unit": "seconds"
                ],
                "transactionMetrics": metrics.transactionMetrics.map { tx in
                    var metrics: [String: Any] = [
                        "isCellular": tx.isCellular,
                        "isExpensive": tx.isExpensive,
                        "isConstrained": tx.isConstrained,
                        "isProxyConnection": tx.isProxyConnection,
                        "isReusedConnection": tx.isReusedConnection,
                        "isMultipath": tx.isMultipath
                    ]

                    if let fetchStartDate = tx.fetchStartDate {
                        metrics["fetchStartDate"] = fetchStartDate
                            .timeIntervalSince1970
                    }

                    if let responseEndDate = tx.responseEndDate {
                        metrics["responseEndDate"] = responseEndDate
                            .timeIntervalSince1970
                    }

                    if let networkProtocolName = tx.networkProtocolName {
                        metrics["networkProtocolName"] = networkProtocolName
                    }

                    if let remotePort = tx.remotePort {
                        metrics["remotePort"] = remotePort
                    }

                    if let remoteAddress = tx.remoteAddress {
                        metrics["remoteAddress"] = remoteAddress
                    }

                    return metrics
                }
            ]
        )
    }
}
