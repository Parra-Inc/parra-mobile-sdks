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
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not get user properties. Not logged in."
            )
        }

        return try await hitEndpoint(
            .getUserProperties(userId: userInfo.id),
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }

    func replaceUserProperties(
        _ properties: UserProperties
    ) async throws -> UserProperties {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not replace user properties. Not logged in."
            )
        }

        return try await hitEndpoint(
            .putReplaceUserProperties(userId: userInfo.id),
            body: properties
        )
    }

    func upsertUserProperties(
        _ properties: UserProperties
    ) async throws -> UserProperties {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not upsert user properties. Not logged in."
            )
        }

        return try await hitEndpoint(
            .patchUpdateUserProperties(userId: userInfo.id),
            body: properties
        )
    }

    func deleteAllUserProperties() async throws -> UserProperties {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not delete user properties. Not logged in."
            )
        }

        return try await hitEndpoint(
            .deleteAllUserProperties(userId: userInfo.id)
        )
    }

    func updateSingleUserProperty(
        _ property: String,
        value: ParraAnyCodable
    ) async throws -> UserProperties {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not update user property. Not logged in."
            )
        }

        let body = UserPropertyValue(value: value)

        return try await hitEndpoint(
            .putUpdateSingleUserProperty(
                userId: userInfo.id,
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
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not delete user property. Not logged in."
            )
        }

        return try await hitEndpoint(
            .deleteSingleUserProperty(
                userId: userInfo.id,
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
