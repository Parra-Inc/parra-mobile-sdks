//
//  ParraError.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraError: LocalizedError, CustomStringConvertible {
    case message(String)
    case generic(String, Error?)
    case notInitialized
    case missingAuthentication
    case authenticationFailed(String)
    case networkError(
        request: URLRequest,
        response: HTTPURLResponse,
        responseData: Data
    )
    case apiError(ParraApiErrorResponse)
    case fileSystem(path: URL, message: String)
    case jsonError(String)
    case system(Error)
    case validationFailed(failures: [String: String])
    case unknown

    // MARK: - Public

    public var localizedDescription: String {
        return description
    }

    /// A simple error description string for cases where we don't have more
    /// complete control over the output formatting. Interally, we want to
    /// always use `Parra/ParraErrorWithExtra` in combination with the
    /// `ParraError/errorDescription` and ``ParraError/description`` fields
    /// instead of this.
    public var description: String {
        let baseMessage = errorDescription

        switch self {
        case .message, .unknown, .jsonError, .notInitialized,
             .missingAuthentication:
            return baseMessage
        case .generic(_, let error):
            if let error {
                return "\(baseMessage) Error: \(error)"
            }

            return baseMessage
        case .authenticationFailed(let error):
            return "\(baseMessage) Error: \(error)"
        case .apiError(let error):
            return "An API error occurred. Server provided message: \(error.message)"
        case .networkError(let request, let response, let data):
            let serverMessage = extractErrorMessage(from: data)

            let method = request.httpMethod?.uppercased() ?? "UNKNOWN"

            let message = """
                \(baseMessage) (Note: URL params are omitted from output)
                Status: \(response.statusCode)
                Request URL: \(method) \(
                request.url?
                .absoluteString ?? "unknown"
                )
                Message: \(serverMessage ?? "Server did not provide a message.")
                Request: \(request)
                Response: \(response)
                """

            #if DEBUG
            let dataString = String(data: data, encoding: .utf8) ?? "unknown"

            return "\(message)\nData: \(dataString)"
            #else
            return "\(message)\nData: \(data.count) byte(s)"
            #endif
        case .fileSystem(let path, let message):
            return "\(baseMessage)\nPath: \(path.relativeString)\nError: \(message)"
        case .system(let error):
            return "Error: \(error)"
        case .validationFailed(let failures):
            return failures.reduce(baseMessage) { partialResult, next in
                return "\(partialResult)\n\(next.key): \(next.value)"
            }
        }
    }

    // MARK: - Internal

    var isUnauthenticated: Bool {
        switch self {
        case .networkError(_, let response, _):
            return response.statusCode == 401
        default:
            return false
        }
    }

    var userMessage: String? {
        switch self {
        case .apiError(let response):
            return response.message
        case .networkError(_, _, let data):
            return extractErrorMessage(from: data)
        default:
            return nil
        }
    }

    var errorDescription: String {
        switch self {
        case .message(let string):
            return string
        case .generic(let string, let error):
            if let error {
                let formattedError = LoggerFormatters
                    .extractMessage(from: error)

                return "\(string) Error: \(formattedError)"
            }

            return string
        case .notInitialized:
            return "Parra has not been initialized. Call Parra.initialize() in applicationDidFinishLaunchingWithOptions."
        case .missingAuthentication:
            return "An authentication provider has not been set. Add Parra.initialize() to your applicationDidFinishLaunchingWithOptions method."
        case .authenticationFailed:
            return "Invoking the authentication provider passed to Parra.initialize() failed."
        case .networkError, .apiError:
            return "A network error occurred."
        case .jsonError(let string):
            return "JSON error occurred. Error: \(string)"
        case .fileSystem:
            return "A file system error occurred."
        case .unknown:
            return "An unknown error occurred."
        case .system(let error):
            let formattedError = LoggerFormatters.extractMessage(from: error)

            return "\(formattedError)"
        case .validationFailed:
            return "Validation failed."
        }
    }

    // MARK: - Private

    private func extractErrorMessage(from body: Data?) -> String? {
        guard let body else {
            return nil
        }

        guard let decoded = try? JSONDecoder.parraDecoder.decode(
            [String: String].self,
            from: body
        ) else {
            return nil
        }

        return decoded["message"]
    }
}

// MARK: ParraSanitizedDictionaryConvertible

extension ParraError: ParraSanitizedDictionaryConvertible {
    var sanitized: ParraSanitizedDictionary {
        switch self {
        case .generic(_, let error):
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
        case .apiError(let error):
            return [
                "type": error.type
            ]
        case .networkError(let request, let response, let body):
            var bodyInfo: [String: Any] = [
                "length": body.count
            ]

            #if DEBUG
            let dataString = String(
                data: body,
                encoding: .utf8
            ) ?? "unknown"

            bodyInfo["data"] = dataString
            #endif

            return [
                "request": request.sanitized.dictionary,
                "response": response.sanitized.dictionary,
                "body": bodyInfo
            ]
        case .fileSystem(let path, let message):
            return [
                "path": path.relativeString,
                "error_description": message
            ]
        case .notInitialized, .missingAuthentication, .message, .jsonError,
             .unknown, .system:

            return [:]
        case .validationFailed(let failures):
            return ParraSanitizedDictionary(dictionary: failures)
        }
    }
}
