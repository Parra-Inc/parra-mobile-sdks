//
//  ParraUserProperties+setters.swift
//  Parra
//
//  Created by Mick MacCallum on 9/22/24.
//

import Foundation

private let maxKeyLength = 128
private let maxStringValueLength = 1_024
private let logger = ParraLogger(category: "Parra User Properties")

public extension ParraUserProperties {
    func deleteValue(for key: String) {
        Task {
            do {
                try await deleteValue(for: key)
            } catch {
                logger.error(
                    "Error deleting value for key: \(key)",
                    error,
                    [
                        "key": key
                    ]
                )
            }
        }
    }

    func deleteValue(for key: String) async throws {
        let oldValue = rawValue[key]
        rawValue.removeValue(forKey: key)

        let api = await Parra.default.parraInternal.api

        return try await withCheckedThrowingContinuation { continuation in
            api.deleteSingleUserProperty(key)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            continuation.resume()
                        case .failure(let error):
                            // If the delete failed, revert to the old value.
                            self?.rawValue[key] = oldValue
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { [weak self] newStore in
                        self?.updateStore(newStore)
                    }
                )
                .store(in: &cancellables)
        }
    }

    func set(_ string: String, for key: String) {
        try? validateStringValue(string, for: key)

        set(ParraAnyCodable(string), for: key)
    }

    func set(_ string: String, for key: String) async throws {
        try validateStringValue(string, for: key)

        try await set(ParraAnyCodable(string), for: key)
    }

    func set(_ int: Int, for key: String) {
        set(ParraAnyCodable(int), for: key)
    }

    func set(_ int: Int, for key: String) async throws {
        try await set(ParraAnyCodable(int), for: key)
    }

    func set(_ double: Double, for key: String) {
        set(ParraAnyCodable(double), for: key)
    }

    func set(_ double: Double, for key: String) async throws {
        try await set(ParraAnyCodable(double), for: key)
    }

    func set(_ bool: Bool, for key: String) {
        set(ParraAnyCodable(bool), for: key)
    }

    func set(_ bool: Bool, for key: String) async throws {
        try await set(ParraAnyCodable(bool), for: key)
    }

    internal func validateKey(
        _ key: String
    ) throws {
        if key.count > maxKeyLength {
            logger.error(
                "Key is too long. Must be less than \(maxKeyLength) characters.",
                [
                    "key": key
                ]
            )

            throw ParraError.message(
                "Key \(key) is too long. Must be less than \(maxKeyLength) characters."
            )
        }
    }

    internal func validateStringValue(
        _ value: String,
        for key: String
    ) throws {
        if value.count > maxStringValueLength {
            logger.error(
                "Value for key is too long. Must be less than \(maxStringValueLength) characters.",
                [
                    "key": key,
                    "value": value
                ]
            )

            throw ParraError.message(
                "Value for key \(key) is too long. Must be less than \(maxStringValueLength) characters."
            )
        }
    }
}
