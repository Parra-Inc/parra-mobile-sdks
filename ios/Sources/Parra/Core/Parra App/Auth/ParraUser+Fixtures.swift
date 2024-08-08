//
//  ParraUser+Fixtures.swift
//
//
//  Created by Mick MacCallum on 8/8/24.
//

import SwiftUI

public extension ParraAuthState {
    public static let authenticatedPreview = ParraAuthState.authenticated(
        .authenticatedPreview
    )

    public static let unauthenticatedPreview = ParraAuthState.guest(
        .authenticatedPreview
    )
}

public extension ParraUser {
    public static let authenticatedPreview = ParraUser(
        credential: .basic("invalid-preview-token"),
        info: .publicFacingPreview
    )
}

public extension ParraGuest {
    public static let authenticatedPreview = ParraGuest(
        credential: .basic("invalid-preview-token")
    )
}
