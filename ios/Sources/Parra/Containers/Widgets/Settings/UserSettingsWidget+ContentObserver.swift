//
//  UserSettingsWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import Combine
import SwiftUI

private let logger = Logger()

// MARK: - UserSettingsWidget.ContentObserver

extension UserSettingsWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.layoutId = initialParams.layoutId
            self.config = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.loadState = if let layout = initialParams.layout {
                .loaded(layout)
            } else {
                .initial
            }
        }

        // MARK: - Internal

        enum LoadState: Equatable {
            case initial
            case loading
            case loaded(ParraUserSettingsLayout)
            case error(Error)

            // MARK: - Internal

            static func == (
                lhs: UserSettingsWidget.ContentObserver.LoadState,
                rhs: UserSettingsWidget.ContentObserver.LoadState
            ) -> Bool {
                switch (lhs, rhs) {
                case (.initial, .initial):
                    return true
                case (.loading, .loading):
                    return true
                case (.loaded(let lhsLayout), .loaded(let rhsLayout)):
                    return lhsLayout == rhsLayout
                case (.error(let lhsError), .error(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                default:
                    return false
                }
            }
        }

        private(set) var loadState: LoadState

        let content: Content

        func loadSettingsLayout() async {
            loadState = .loading

            do {
                let layout = try await api.getSettingsLayout(
                    layoutId: layoutId
                )

                loadState = .loaded(layout)
            } catch {
                loadState = .error(error)
            }
        }

        func updateSetting(
            with key: String,
            to value: ParraSettingsItemDataWithValue
        ) async throws {
            guard case .loaded(let layout) = loadState else {
                return
            }

            // need to set this before updating user setting, since it may
            // trigger other state updates that cause refreshes.
            loadState = .loaded(
                layout.withUpdatedValue(value: value, for: key)
            )

            do {
                try await ParraUserSettings.shared.updateSetting(
                    with: key,
                    to: value
                )
            } catch {
                // revert
                loadState = .loaded(layout)

                throw error
            }
        }

        // MARK: - Private

        private let layoutId: String
        private let api: API
        private let config: ParraUserSettingsConfiguration
        private var cancellables: Set<AnyCancellable> = []
    }
}
