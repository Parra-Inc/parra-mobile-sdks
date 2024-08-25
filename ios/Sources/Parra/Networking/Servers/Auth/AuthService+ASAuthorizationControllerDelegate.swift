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

    @MainActor
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
    @MainActor
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        let addr = Unmanaged.passUnretained(controller).toOpaque()

        guard let (_, completion) = activeAuthorizationRequests[addr] else {
            logger.warn(
                "Received authorization error callback for unknown request",
                error
            )

            return
        }

        guard let error = error as? ASAuthorizationError else {
            completion(
                .failure(
                    ASAuthorizationError(
                        _nsError: NSError(
                            domain: "\(ParraInternal.errorDomain).authorization",
                            code: 1_082
                        )
                    )
                )
            )

            return
        }

        completion(.failure(error))

        activeAuthorizationRequests.removeValue(forKey: addr)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        let addr = Unmanaged.passUnretained(controller).toOpaque()

        guard let (_, completion) = activeAuthorizationRequests[addr] else {
            logger.warn(
                "Received authorization complete callback for unknown request",
                [
                    "authorization": String(describing: authorization)
                ]
            )

            return
        }

        logger.info("Authorization completed", [
            "authorization": String(describing: authorization)
        ])

        completion(.success(authorization))

        activeAuthorizationRequests.removeValue(forKey: addr)
    }

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return UIViewController.safeGetKeyWindow() ?? UIWindow()
    }
}
