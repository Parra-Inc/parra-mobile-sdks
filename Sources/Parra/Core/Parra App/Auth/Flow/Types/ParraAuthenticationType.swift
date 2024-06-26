//
//  ParraAuthenticationType.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraAuthenticationType {
    /// Covers any case where you enter some kind of username to authenticate.
    /// This includes username as well as email and phone number, both when
    /// used as a username and when used with passwordless authentication.
    case credentials
    case sso
}
