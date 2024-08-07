//
//  ChallengeResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraChallengeResponse: Equatable, Sendable {
    case passkey
    case password(password: String, isValid: Bool)
    case passwordlessSms(String)
    case passwordlessEmail(String)
    case verificationSms(String)
    case verificationEmail(String)

    // MARK: - Internal

    var authMethod: ParraAuthenticationMethod? {
        switch self {
        case .passkey:
            return .passkey
        case .password:
            return .password
        case .passwordlessSms:
            return .passwordless(.sms)
        case .passwordlessEmail:
            return .passwordless(.email)
        case .verificationSms, .verificationEmail:
            return nil
        }
    }
}
