//
//  FAQWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import Combine
import SwiftUI

private let logger = Logger()

// MARK: - FAQWidget.ContentObserver

extension FAQWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
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
            case loaded(ParraAppFaqLayout)
            case error(Error)

            // MARK: - Internal

            static func == (
                lhs: ContentObserver.LoadState,
                rhs: ContentObserver.LoadState
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

        func loadFaqs() async {
            loadState = .loading

            do {
                let layout = try await api.getFAQLayout()

                loadState = .loaded(layout)
            } catch {
                loadState = .error(error)
            }
        }

        // MARK: - Private

        private let api: API
        private let config: ParraFAQConfiguration
    }
}
