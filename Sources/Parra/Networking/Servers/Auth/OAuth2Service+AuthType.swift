//
//  OAuth2Service+AuthType.swift
//  Parra
//
//  Created by Mick MacCallum on 4/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension OAuth2Service {
    enum AuthType {
        case emailPassword(email: String, password: String)
        case passwordless(email: String)
        case passwordlessSms(sms: String)
    }
}
