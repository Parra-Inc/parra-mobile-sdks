//
//  AuthenticationFlowManager+ASAuthorizationControllerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 6/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import SwiftUI

class AuthorizationControllerDelegateProxy: NSObject,
    ASAuthorizationControllerDelegate
{
    weak var authenticationFlowManager: AuthenticationFlowManager?

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        authenticationFlowManager?.authorizationController(
            controller: controller,
            didCompleteWithError: error
        )
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        authenticationFlowManager?.authorizationController(
            controller: controller,
            didCompleteWithAuthorization: authorization
        )
    }
}

extension AuthenticationFlowManager {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        guard let error = error as? ASAuthorizationError else {
            return
        }

//        switch error.code {
//
//        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {}
}
