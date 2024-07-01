//
//  ChallengeResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ChallengeResponse {
    case passkey
    case password(String)
    case passwordlessSms(String)
    case passwordlessEmail(String)
    case verificationSms(String)
    case verificationEmail(String)
}
