//
//  IssuerEndpoint.swift
//  Parra
//
//  Created by Mick MacCallum on 6/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum IssuerEndpoint: Endpoint {
    case postCreateUser
    case postAuthChallenges
    case postPasswordless
    case postWebAuthnRegisterChallenge
    case postWebAuthnAuthenticateChallenge
    case postWebAuthnRegister
    case postWebAuthnAuthenticate
    case postAuthentication
    case postForgotPassword
    case postResetPassword

    // MARK: - Internal

    var method: HttpMethod {
        switch self {
        case .postAuthChallenges, .postCreateUser, .postPasswordless,
             .postWebAuthnAuthenticate, .postWebAuthnAuthenticateChallenge,
             .postWebAuthnRegister, .postWebAuthnRegisterChallenge,
             .postAuthentication, .postForgotPassword, .postResetPassword:
            return .post
        }
    }

    var slug: String {
        switch self {
        case .postCreateUser:
            return "auth/signup"
        case .postAuthChallenges:
            return "auth/challenges"
        case .postPasswordless:
            return "auth/challenges/passwordless"
        case .postWebAuthnRegisterChallenge:
            return "auth/webauthn/register/challenge"
        case .postWebAuthnAuthenticateChallenge:
            return "auth/webauthn/authenticate/challenge"
        case .postWebAuthnRegister:
            return "auth/webauthn/register"
        case .postWebAuthnAuthenticate:
            return "auth/webauthn/authenticate"
        case .postAuthentication:
            return "auth/issuers/public/token"
        case .postForgotPassword:
            return "auth/password/reset/challenge"
        case .postResetPassword:
            return "auth/password/reset"
        }
    }

    var isTrackingEnabled: Bool {
        switch self {
        // MUST check backend before removing any from this list
        case .postAuthentication:
            return true
        default:
            return false
        }
    }
}
