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

    public internal(set) var rawValue: [String: ParraAnyCodable] = [:]

    // MARK: - Internal

    static let shared = ParraUserProperties()

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
}
