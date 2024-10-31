//
//  ParraUserSettings.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import Combine
import SwiftUI

private let logger = ParraLogger(category: "Parra User Settings")

@Observable
public final class ParraUserSettings: ParraReadableKeyValueStore {
    // MARK: - Public

    public let currentPublisher = PassthroughSubject<[String: ParraAnyCodable], Never>()

    public internal(set) var rawValue: [String: ParraAnyCodable] = [:] {
        didSet {
            currentPublisher.send(rawValue)
        }
    }

    public var current: [String: ParraAnyCodable] {
        return rawValue
    }

    // MARK: - Internal

    static let shared = ParraUserSettings()

    @MainActor
    func updateSetting(
        with key: String,
        to value: ParraSettingsItemDataWithValue
    ) async throws {
        let oldValue = rawValue[key]

        return try await withCheckedThrowingContinuation { continuation in
            Parra.default.parraInternal.api.updateSettingValuePublisher(
                for: key,
                with: value
            )
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
                receiveValue: { [weak self] updatedSetting in
                    self?.rawValue[key] = updatedSetting.rawValue
                }
            )
            .store(in: &cancellables)
        }
    }

    /// Override the previous store with no conflict resolution or publishers.
    /// Only use this when initially setting the store after app launch.
    func updateSettings(_ newStore: [String: ParraAnyCodable]) {
        logger.trace("Setting initial user settings")

        rawValue = newStore
    }

    /// Invoke this on logout before new user info is available to drop all the
    /// current user property state.
    func reset() {
        logger.trace("Resetting user settings")

        rawValue = [:]
    }

    // MARK: - Private

    private var cancellables: Set<AnyCancellable> = []
}
