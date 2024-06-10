//
//  ParraAuthDefaultIdentityInputScreen+Params.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthDefaultIdentityInputScreen {
    struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            inputType: ParraIdentityInputType,
            submitIdentity: @escaping (_ identity: String) async throws -> Void,
            attemptPasskeyAutofill: (() async throws -> Void)? = nil
        ) {
            self.inputType = inputType
            self.submitIdentity = submitIdentity
            self.attemptPasskeyAutofill = attemptPasskeyAutofill
        }

        // MARK: - Public

        /// The type of identity input to request from the user.
        public let inputType: ParraIdentityInputType

        /// A value for the provided `inputType` has been collected from the
        /// user. Invoke this when you're ready to transition to the next
        /// screen. In the default flow provider, this means checking if a user
        /// exists and providing a challenge.
        public let submitIdentity: (_ identity: String) async throws -> Void

        /// Only provided when the input type is NOT `.passkey`. This method
        /// should be called as early as possible and is used to attempt to
        /// place passkey autofill suggestions in the QuickType bar.
        public let attemptPasskeyAutofill: (() async throws -> Void)?
    }
}
