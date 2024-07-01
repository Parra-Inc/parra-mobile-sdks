//
//  ASAuthorizationError+noCredential.swift
//  Parra
//
//  Created by Mick MacCallum on 6/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices

extension ASAuthorizationError {
    var noPasskeysAvailable: Bool {
        // For some reason Apple doesn't have a unique error code for this case
        // and when no credentials are available, a user canceled error will
        // be thrown.

        guard code == .canceled else {
            return false
        }

        guard let reason =
            userInfo[NSLocalizedFailureReasonErrorKey] as? String else
        {
            return false
        }

        return reason.contains("No credentials available for login.")
    }
}
