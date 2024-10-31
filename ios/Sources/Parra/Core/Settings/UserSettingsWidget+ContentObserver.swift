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

        private(set) var loadState: LoadState = .initial

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

        // MARK: - Private

        private let layoutId: String
        private let api: API
        private let config: ParraUserSettingsConfiguration
    }
}
