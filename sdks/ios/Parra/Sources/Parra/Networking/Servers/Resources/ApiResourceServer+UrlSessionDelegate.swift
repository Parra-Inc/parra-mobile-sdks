//
//  ApiResourceServer+UrlSessionDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 7/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ApiResourceServer: UrlSessionDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) async {
        logMetrics(metrics, for: task)
    }
}
