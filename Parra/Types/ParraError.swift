//
//  ParraError.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraError: LocalizedError, CustomStringConvertible {
    case message(String)
    case custom(String, Error?)
    case notInitialized
    case missingAuthentication
    case authenticationFailed(String)
    case networkError(request: URLRequest, response: HTTPURLResponse)
    case fileSystem(path: URL, message: String)
    case jsonError(String)
    case unknown

    internal var errorDescription: String {
        switch self {
        case .message(let string):
            return string
        case .custom(let string, _):
            return string
        case .notInitialized:
            return "Parra has not been initialized. Call Parra.initialize() in applicationDidFinishLaunchingWithOptions."
        case .missingAuthentication:
            return "An authentication provider has not been set. Add Parra.initialize() to your applicationDidFinishLaunchingWithOptions method."
        case .authenticationFailed:
            return "Invoking the authentication provider passed to Parra.initialize() failed."
        case .networkError:
            return "A network error occurred."
        case .jsonError(let string):
            return "JSON error occurred. Error: \(string)"
        case .fileSystem:
            return "A file system error occurred."
        case .unknown:
            return "An unknown error occurred."
        }
    }

    /// A simple error description string for cases where we don't have more complete control over the output formatting.
    /// Interally, we want to always use ``ParraErrorWithExtra`` in combination with the ``errorDescription`` and
    /// ``dictionary`` fields instead of this.
    public var description: String {
        let baseMessage = errorDescription

        switch self {
        case .message, .unknown, .jsonError, .notInitialized, .missingAuthentication:
            return baseMessage
        case .custom(_, let error):
            if let error {
                return "\(baseMessage) Error: \(error)"
            }

            return baseMessage
        case .authenticationFailed(let error):
            return "\(baseMessage) Error: \(error)"
        case .networkError(let request, let response):
            return "\(baseMessage)\nRequest: \(request)\nResponse: \(response)"
        case .fileSystem(let path, let message):
            return "\(baseMessage)\nPath: \(path.relativeString)\nError: \(message)"
        }
    }
}

extension ParraError: ParraDictionaryConvertible {
    var dictionary: [String : Any] {
        switch self {
        case .custom(_, let error):
            if let error {
                return [
                    "error_description": error.localizedDescription
                ]
            }

            return [:]
        case .authenticationFailed(let error):
            return [
                "authentication_error": error
            ]
        case .networkError(let request, let response):
            return [
                "request": request.dictionary,
                "response": response.dictionary
            ]
        case .fileSystem(let path, let message):
            return [
                "path": path.relativeString,
                "error_description": message
            ]
        case .notInitialized, .missingAuthentication, .message, .jsonError, .unknown:
            return [:]
        }
    }
}
