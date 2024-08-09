//
//  ParraUser+Fixtures.swift
//
//
//  Created by Mick MacCallum on 8/8/24.
//

import SwiftUI

public extension ParraAuthState {
    static let authenticatedPreview = ParraAuthState.authenticated(
        .authenticatedPreview
    )

    static let unauthenticatedPreview = ParraAuthState.guest(
        .authenticatedPreview
    )
}

public extension ParraUser {
    static let authenticatedPreview = ParraUser(
        credential: .basic("invalid-preview-token"),
        info: .publicFacingPreview
    )
}

public extension ParraGuest {
    static let authenticatedPreview = ParraGuest(
        credential: .basic("invalid-preview-token")
    )
}
