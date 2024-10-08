//
//  Providers.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public protocol ParraAuthScreenParams {}
public protocol ParraAuthScreenConfig {
    static var `default`: Self { get }
}

@MainActor
public protocol ParraAuthScreen: View, Equatable {
    associatedtype Params: ParraAuthScreenParams
    associatedtype Config: ParraAuthScreenConfig

    init(params: Params, config: Config)
}

public typealias ParraAuthScreenProvider<T> = @MainActor (T.Params) -> T
    where T: ParraAuthScreen & Equatable

public typealias ParraAuthLandingScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultLandingScreen>

public typealias ParraAuthIdentityInputScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityInputScreen>

public typealias ParraAuthIdentityChallengeScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityChallengeScreen>

public typealias ParraAuthIdentityVerificationScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultIdentityVerificationScreen>

public typealias ParraAuthForgotPasswordScreenProvider =
    ParraAuthScreenProvider<ParraAuthDefaultForgotPasswordScreen>

public enum ParraAuthScreenOption<T: ParraAuthScreen> {
    case `default`(_ config: T.Config)
    case custom(_ provider: ParraAuthScreenProvider<T>)
}
