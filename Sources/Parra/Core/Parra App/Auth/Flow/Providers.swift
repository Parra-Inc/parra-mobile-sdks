//
//  Providers.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum LoginMethod {
    case emailOrPhone
    case sso(SSO)

    // MARK: - Public

    public enum SSO {
        case google
        case apple
        case facebook
    }
}

public typealias LandingScreenProvider = (
    _ selectLoginMethod: @escaping (LoginMethod) -> Void
) -> any View

public typealias EmailInputScreenProvider = (
    _ submitEmail: @escaping (_ email: String) -> Void
) -> any View

public typealias PasswordInputScreenProvider = (
    _ email: String,
    _ submitPassword: @escaping (_ password: String) -> Void,
    _ loginWithoutPassword: @escaping () -> Void
) -> any View
