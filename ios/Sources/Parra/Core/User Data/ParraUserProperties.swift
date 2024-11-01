//
//  ParraUserProperties.swift
//
//
//  Created by Mick MacCallum on 9/21/24.
//

import Combine
import SwiftUI

private let logger = ParraLogger(category: "Parra User Properties")

/// User Properties allow you to attach semi-arbitrary information to your user.
/// User properties are synchronized between your user's accounts across their
/// devices and can be used to store any information you'd like to associate
/// with them, subject to the following:
/// * A maximum of 100 key/value pairs.
/// * A 128 character limit for keys.
/// * Values are limited to strings, numbers and bools.
/// * A 1,024 character limit for values that are strings.
///
/// Bools, Ints, Doubles, etc are converted to NSNumber and stored as numbers
/// on the backend.
@Observable
public final class ParraUserProperties: ParraReadableKeyValueStore {
    // MARK: - Public

    public internal(set) var rawValue: [String: ParraAnyCodable] = [:]

    public let conflictPublisher = PassthroughSubject<MergeConflict, Never>()

    // MARK: - Internal

    static let shared = ParraUserProperties()

    var cancellables: Set<AnyCancellable> = []

    @MainActor
    func resolveConflict(
        _ conflict: MergeConflict,
        with resolution: MergeConflict.Resolution
    ) {
        let value = switch resolution {
        case .keepNew:
            conflict.newValue
        case .keepOld:
            conflict.oldValue
        }

        set(value, for: conflict.key)
    }

    /// Override the previous store with no conflict resolution or publishers.
    /// Only use this when initially setting the store after app launch.
    @MainActor
    func forceSetStore(_ newStore: [String: ParraAnyCodable]) {
        logger.trace("Setting initial user properties")

        rawValue = newStore
    }

    /// Invoke this on logout before new user info is available to drop all the
    /// current user property state.
    @MainActor
    func reset() {
        logger.trace("Resetting user properties")

        rawValue = [:]
        cancellables.removeAll()
    }

    @MainActor
    func set(
        _ value: ParraAnyCodable,
        for key: String
    ) {
        Task {
            do {
                try await set(value, for: key)
            } catch {
                logger.error(
                    "Error setting value for key: \(key)",
                    error,
                    [
                        "key": key
                    ]
                )
            }
        }
    }

    @MainActor
    func set(
        _ value: ParraAnyCodable,
        for key: String
    ) async throws {
        try validateKey(key)

        let oldValue = rawValue[key]
        rawValue[key] = value

        let api = Parra.default.parraInternal.api

        return try await withCheckedThrowingContinuation { continuation in
            api.updateSingleUserPropertyPublisher(key, value: value)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            continuation.resume()
                        case .failure(let error):
                            // If the update failed, revert to the old value.
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

    @MainActor
    func updateStore(
        _ newStore: [String: ParraAnyCodable]
    ) {
        logger.trace("Updating store for user properties")

        var conflictsExisted = false

        for (key, newValue) in newStore {
            if let oldValue = rawValue[key], oldValue != newValue {
                if !conflictsExisted {
                    conflictsExisted = true
                }

                let conflict = MergeConflict(
                    key: key,
                    oldValue: oldValue,
                    newValue: newValue,
                    resolver: resolveConflict
                )

                conflictPublisher.send(conflict)
            }
        }

        rawValue = newStore
    }
}
