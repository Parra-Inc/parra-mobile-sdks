//
//  SignInWithAppleTokenPayload.swift
//  Parra
//
//  Created by Mick MacCallum on 12/2/24.
//

import AuthenticationServices
import Foundation

struct SignInWithAppleTokenPayload {
    // MARK: - Lifecycle

    init(
        credential: ASAuthorizationAppleIDCredential
    ) throws {
        guard let authCodeData = credential.authorizationCode,
              let authCodeString = String(data: authCodeData, encoding: .utf8) else
        {
            throw ParraError.message(
                "Sign in with Apple failed to decode authorization code."
            )
        }

        guard let idTokenData = credential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else
        {
            throw ParraError.message(
                "Sign in with Apple failed to decode identity token."
            )
        }

        self.idToken = idTokenString
        self.authCode = authCodeString
        self.email = credential.email
        self.name = SignInWithAppleUserName(credential.fullName)
    }

    // MARK: - Internal

    let authCode: String
    let idToken: String
    let email: String?
    let name: SignInWithAppleUserName

    var dictionary: [String: String] {
        var dict: [String: String] = name.dictionary

        dict["grant_type"] = "sign_in_with_apple"
        dict["code"] = authCode
        dict["id_token"] = idToken

        if let email {
            dict["email"] = email
        }

        return dict
    }
}
