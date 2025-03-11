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
        let completion = activeAuthorizationRequest?.1

        defer {
            activeAuthorizationRequest = nil
        }

        guard let error = error as? ASAuthorizationError else {
            logger.error(
                "Received unexpected authorization error callback",
                error
            )

            completion?(
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

        if completion == nil && error.code != .canceled {
            logger.warn(
                "Received authorization error callback for unknown request",
                error
            )
        } else {
            let authErrorName = switch error.code {
            case .canceled:
                "canceled"
            case .credentialExport:
                "credentialExport"
            case .credentialImport:
                "credentialImport"
            case .failed:
                "failed"
            case .invalidResponse:
                "invalidResponse"
            case .matchedExcludedCredential:
                "matchedExcludedCredential"
            case .notHandled:
                "notHandled"
            case .notInteractive:
                "notInteractive"
            case .unknown:
                "unknown"
            @unknown default:
                "unknown-default"
            }

            logger.debug("Authorization failure with code: \(authErrorName)")

            completion?(.failure(error))
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let (_, completion) = activeAuthorizationRequest else {
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

        activeAuthorizationRequest = nil
    }

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return UIViewController.safeGetKeyWindow() ?? UIWindow()
    }
}
