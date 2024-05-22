//
//  Providers.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum AuthenticationMethod: Equatable {
    case passwordless(PasswordlessType)
    case password // implies email
    case sso(SsoType)
    case passkey

    // MARK: - Public

    public enum SsoType {
        case google
        case apple
        case facebook
    }

    public enum PasswordlessType {
        case sms
        case email
    }
}

public enum ChallengeType {
    case password(validationRules: [TextValidatorRule])
    case passwordlessSms(codeLength: Int)
    case passwordlessEmail(codeLength: Int)
}

public enum IdentityType {
    case email
    case phone
    case username
}

public enum ChallengeResponse {
    case password(String)
    case passwordlessSms(String)
    case passwordlessEmail(String)
}

// app info endpoint will contain list of available login methods

public protocol ParraAuthScreenParams {}
public protocol ParraAuthScreen: View {
    associatedtype Params: ParraAuthScreenParams

    init(params: Params)
}

public typealias ParraAuthScreenProvider<T> = (T.Params) -> T
    where T: ParraAuthScreen

public typealias ParraAuthLandingScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultLandingScreen>

// collects email or phone number. has continue button. server will respond to
// continue action with info necessary to draw the next page
public typealias ParraAuthIdentityInputScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityInputScreen>
// --> identity from server after this ^^^

// if password and passwordless -> show password field and "login with out password" button which navigates to passwordless screen
// if password only, don't show "login without password"
// if passwordless only show the passwordless screen
public typealias ParraAuthIdentityChallengeScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityChallengeScreen>
