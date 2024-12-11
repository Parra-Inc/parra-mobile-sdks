//
//  ReactionWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import Combine
import SwiftUI

extension ReactionWidget {
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.content = Content()
        }

        // MARK: - Internal

        @Published private(set) var content: Content
    }
}
