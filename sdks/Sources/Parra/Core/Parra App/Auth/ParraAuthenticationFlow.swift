//
//  ParraAuthenticationFlow.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public protocol ParraAuthenticationFlowDelegate {
    func completeAuthentication(
        with user: ParraUser
    )
}

/// A view that represents a flow of authentication screens. These views are
/// responsible for rendering anything necessary to get a user from a logged out
/// to logged in state. They are expected to take a configuration object that
/// describes the auth flows that will be possible, and a completion closure
/// which will be called once a user's credentials have been obtained.
public protocol ParraAuthenticationFlow: View {
    var delegate: ParraAuthenticationFlowDelegate? { get set }

    init(
        flowConfig: ParraAuthenticationFlowConfig
    )
}
