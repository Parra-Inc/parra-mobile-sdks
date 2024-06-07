//
//  AuthService+ASAuthorizationControllerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 6/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import SwiftUI

private let logger = Logger()

class AuthorizationControllerDelegateProxy: NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    weak var authService: AuthService?

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        authService?.authorizationController(
            controller: controller,
            didCompleteWithError: error
        )
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        authService?.authorizationController(
            controller: controller,
            didCompleteWithAuthorization: authorization
        )
    }

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return authService?.presentationAnchor(
            for: controller
        ) ?? UIWindow()
    }
}

extension AuthService {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        guard let error = error as? ASAuthorizationError else {
            return
        }

        logger.error("Error from authorization controller", error, [
            "code": error.code.rawValue
        ])

        switch error.code {
        case .canceled:
            logger.info("Authorization was canceled")
        case .unknown:
            logger.error("An unknown error occurred")
        case .invalidResponse:
            logger.error("Invalid response")
        case .notHandled:
            logger.error("Authorization request not handled")
        case .failed:
            logger.error("Authorization request failed")
        case .notInteractive:
            logger.error("Authorization request not interactive")
        default:
            logger.error("Unhandled authorization error")
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization
            .credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration
        {
            // Take steps to handle the registration.
            let dataString = String(
                data: credential.rawClientDataJSON,
                encoding: .utf8
            )!

            print("++++++++++++++++++++++++++++")
            print(dataString)
        } else if let credential = authorization
            .credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion
        {
            // Take steps to verify the challenge.
            let dataString = String(
                data: credential.rawClientDataJSON,
                encoding: .utf8
            )!

            print("-------------------------------")
            print(dataString)
        } else {
            logger.error("Unhandled authorization credential")
            print(authorization)
        }
    }

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return UIViewController.safeGetKeyWindow() ?? UIWindow()
    }
}
