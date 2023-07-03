//
//  MockURLSessionDataTask.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal class MockURLSessionDataTask: URLSessionDataTask {
    let request: URLRequest
    let dataTaskResolver: DataTaskResolver
    let handler: (DataTaskResponse) -> Void

    required init(
        request: URLRequest,
        dataTaskResolver: @escaping DataTaskResolver,
        handler: @escaping (DataTaskResponse) -> Void
    ) {
        self.request = request
        self.dataTaskResolver = dataTaskResolver
        self.handler = handler
    }

    override func resume() {
        Task {
            let (data, response, error) = dataTaskResolver(request)

            try await Task.sleep(ms: 100)

            handler((data, response, error))
        }
    }
}
