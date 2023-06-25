//
//  ParraNetworkManagerTests+Mocks.swift
//  ParraTests
//
//  Created by Mick MacCallum on 4/2/22.
//

import Foundation
@testable import Parra

protocol URLSessionDataTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskType {}

class MockURLSessionDataTask: URLSessionDataTask {
    let request: URLRequest
    let dataTaskResolver: (_ request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?)
    let handler: (Data?, URLResponse?, Error?) -> Void

    required init(request: URLRequest,
                  dataTaskResolver: @escaping (_ request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?),
                  handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.request = request
        self.dataTaskResolver = dataTaskResolver
        self.handler = handler
    }

    override func resume() {
        Task {
            let (data, response, error) = dataTaskResolver(request)
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            handler(data, response, error)
        }
    }
}

class MockURLSession: URLSessionType {
    var configuration: URLSessionConfiguration = .default

    func dataForRequest(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        return try await data(for: request, delegate: delegate)
    }
    
    let dataTaskResolver: (_ request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?)

    required init(dataTaskResolver: @escaping (_ request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?)) {
        self.dataTaskResolver = dataTaskResolver
    }

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        let (data, response, error) = dataTaskResolver(request)
                
        if let error {
            throw error
        }

        return (data!, response!)
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        return MockURLSessionDataTask(
            request: request,
            dataTaskResolver: dataTaskResolver,
            handler: completionHandler
        )
    }
}
