//
//  API.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

private let logger = Logger(category: "Endpoints")

final class API {
    // MARK: - Lifecycle

    init(
        appState: ParraAppState,
        apiResourceServer: ApiResourceServer
    ) {
        self.appState = appState
        self.apiResourceServer = apiResourceServer
    }

    // MARK: - Internal

    let appState: ParraAppState
    let apiResourceServer: ApiResourceServer

    func hitEndpoint<Response>(
        _ endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable = EmptyRequestObject()
    ) async throws -> Response where Response: Codable {
        let response: AuthenticatedRequestResult<Response> =
            await apiResourceServer.hitApiEndpoint(
                endpoint: endpoint,
                queryItems: queryItems,
                cachePolicy: cachePolicy,
                body: body
            )

        switch response.result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func hitUploadEndpoint<Response>(
        _ endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        formFields: [MultipartFormField]
    ) async throws -> Response where Response: Codable {
        let response: AuthenticatedRequestResult<Response> =
            await apiResourceServer.hitUploadEndpoint(
                endpoint: endpoint,
                formFields: formFields,
                queryItems: queryItems,
                cachePolicy: cachePolicy
            )

        switch response.result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
