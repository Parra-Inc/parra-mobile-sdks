//
//  Providers.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraAuthenticationType {
    /// Covers any case where you enter some kind of username to authenticate.
    /// This includes username as well as email and phone number, both when
    /// used as a username and when used with passwordless authentication.
    case credentials
    case passkey
    case sso
}

public enum ParraAuthenticationMethod: Equatable {
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

public enum ParraIdentityInputType {
    case email
    case phone
    case emailOrPhone
    case passkey
}

public enum ChallengeResponse {
    case password(String)
    case passwordlessSms(String)
    case passwordlessEmail(String)
    case verificationSms(String)
    case verificationEmail(String)
}

public protocol ParraAuthScreenParams {}
public protocol ParraAuthScreen: View {
    associatedtype Params: ParraAuthScreenParams

    init(params: Params)
}

public typealias ParraAuthScreenProvider<T> = (T.Params) -> T
    where T: ParraAuthScreen

public typealias ParraAuthLandingScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultLandingScreen>

public typealias ParraAuthIdentityInputScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityInputScreen>

public typealias ParraAuthIdentityChallengeScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityChallengeScreen>

public typealias ParraAuthIdentityVerificationScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityVerificationScreen>
