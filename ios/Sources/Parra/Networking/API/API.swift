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
        apiResourceServer: ApiResourceServer,
        dataManager: DataManager
    ) {
        self.appState = appState
        self.apiResourceServer = apiResourceServer
        self.dataManager = dataManager
    }

    // MARK: - Internal

    let appState: ParraAppState
    let apiResourceServer: ApiResourceServer
    let dataManager: DataManager

    func hitEndpoint<Response>(
        _ endpoint: ApiEndpoint,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable = EmptyRequestObject(),
        timeout: TimeInterval? = nil
    ) async throws -> Response where Response: Codable {
        let response: AuthenticatedRequestResult<Response> =
            await apiResourceServer.hitApiEndpoint(
                endpoint: endpoint,
                queryItems: queryItems,
                cachePolicy: cachePolicy,
                body: body,
                timeout: timeout
            )

        switch response.result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func hitUploadEndpoint<Response>(
        _ endpoint: ApiEndpoint,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        formFields: [MultipartFormField],
        timeout: TimeInterval? = nil
    ) async throws -> Response where Response: Codable {
        let response: AuthenticatedRequestResult<Response> =
            await apiResourceServer.hitUploadEndpoint(
                endpoint: endpoint,
                formFields: formFields,
                queryItems: queryItems,
                cachePolicy: cachePolicy,
                timeout: timeout
            )

        switch response.result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
