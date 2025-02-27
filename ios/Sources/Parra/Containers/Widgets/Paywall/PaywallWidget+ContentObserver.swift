//
//  PaywallWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import SwiftUI

extension PaywallWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.initialParams = initialParams

            self.content = Content()
        }

        // MARK: - Internal

        var content: Content
        let initialParams: InitialParams

        var submissionHandler: ((_ success: Bool, _ error: Error?) -> Void)?

        func dismiss(with error: Error?) {
            if let error {
                submissionHandler?(false, error)
            } else {
                submissionHandler?(true, nil)
            }
        }
    }
}
