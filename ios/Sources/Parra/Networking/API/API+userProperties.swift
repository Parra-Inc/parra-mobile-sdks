//
//  API+userProperties.swift
//
//
//  Created by Mick MacCallum on 9/22/24.
//

import Combine
import Foundation

private let logger = Logger()

extension API {
    struct UserPropertyValue: Codable {
        let value: ParraAnyCodable
    }

    typealias UserProperties = [String: ParraAnyCodable]

    func getUserProperties() async throws -> UserProperties {
        return try await hitEndpoint(
            .getUserProperties,
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }

    func replaceUserProperties(
        _ properties: UserProperties
    ) async throws -> UserProperties {
        return try await hitEndpoint(
            .putReplaceUserProperties,
            body: properties
        )
    }

    func upsertUserProperties(
        _ properties: UserProperties
    ) async throws -> UserProperties {
        return try await hitEndpoint(
            .patchUpdateUserProperties,
            body: properties
        )
    }

    func deleteAllUserProperties() async throws -> UserProperties {
        return try await hitEndpoint(
            .deleteAllUserProperties
        )
    }

    func updateSingleUserProperty(
        _ property: String,
        value: ParraAnyCodable
    ) async throws -> UserProperties {
        let body = UserPropertyValue(value: value)

        return try await hitEndpoint(
            .putUpdateSingleUserProperty(
                propertyKey: property
            ),
            body: body
        )
    }

    func updateSingleUserPropertyPublisher(
        _ property: String,
        value: ParraAnyCodable
    ) -> AnyPublisher<UserProperties, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let result = try await self.updateSingleUserProperty(
                            property,
                            value: value
                        )
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteSingleUserProperty(
        _ property: String
    ) async throws -> UserProperties {
        return try await hitEndpoint(
            .deleteSingleUserProperty(
                propertyKey: property
            )
        )
    }

    func deleteSingleUserProperty(
        _ property: String
    ) -> AnyPublisher<UserProperties, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let result = try await self.deleteSingleUserProperty(
                            property
                        )

                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
