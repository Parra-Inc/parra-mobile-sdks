//
//  AuthServer+UrlSessionDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 6/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthServer: UrlSessionDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) async {
        logMetrics(metrics, for: task)
    }
}
