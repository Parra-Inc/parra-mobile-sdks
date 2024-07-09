//
//  Server+decode.swift
//  Parra
//
//  Created by Mick MacCallum on 6/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraApiErrorResponse: Codable {
    public let type: String
    public let message: String
}

extension Server {
    /// Attempts to decode the provided data using the provided response type.
    /// If this fails, it attempts to compose an error with an associated object
    /// containing fields from the server's error response object.
    func decodeResponse<T: Decodable>(
        from data: Data,
        as responseType: T.Type
    ) throws -> T {
        do {
            return try configuration.jsonDecoder.decode(
                T.self,
                from: data
            )
        } catch let primaryError {
            do {
                #if DEBUG
                Logger.error(
                    "Failed to decode JSON response object for type: \(responseType). Response:\n\(data.prettyPrintedJSONString())",
                    primaryError
                )
                #else
                Logger.error(
                    "Failed to decode JSON response object for type: \(responseType).",
                    primaryError
                )
                #endif

                throw try ParraError.apiError(
                    configuration.jsonDecoder.decode(
                        ParraApiErrorResponse.self,
                        from: data
                    )
                )
            } catch let secondaryError {
                throw secondaryError
            }
        }
    }
}