//
//  OAuthError.swift
//  Parra
//
//  Created by Mick MacCallum on 12/2/24.
//

import Foundation

enum OAuthError: Error, CustomStringConvertible {
    case invalidRequest
    case invalidClient
    case invalidGrant
    case invalidScope
    case unauthorizedClient
    case unsupportedGrantType

    // MARK: - Lifecycle

    init?(response: HTTPURLResponse, data: Data) {
        switch response.statusCode {
        case 400:
            guard let decoded = try? JSONDecoder.parraDecoder.decode(
                [String: String].self,
                from: data
            ) else {
                return nil
            }

            guard let error = decoded["error"] else {
                return nil
            }

            switch error {
            case "invalid_request":
                self = .invalidRequest
            case "invalid_client":
                self = .invalidClient
            case "invalid_grant":
                self = .invalidGrant
            case "invalid_scope":
                self = .invalidScope
            case "unauthorized_client":
                self = .unauthorizedClient
            case "unsupported_grant_type":
                self = .unsupportedGrantType
            default:
                return nil
            }
        default:
            return nil
        }
    }

    // MARK: - Internal

    var description: String {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .invalidClient:
            return "Invalid client"
        case .invalidGrant:
            return "Invalid grant"
        case .invalidScope:
            return "Invalid scope"
        case .unauthorizedClient:
            return "Unauthorized client"
        case .unsupportedGrantType:
            return "Unsupported grant type"
        }
    }
}
