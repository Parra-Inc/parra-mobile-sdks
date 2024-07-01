//
//  AuthService+PasskeyPresentationMode.swift
//  Parra
//
//  Created by Mick MacCallum on 6/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthService {
    enum PasskeyPresentationMode: CustomStringConvertible {
        case modal
        case autofill

        // MARK: - Internal

        var description: String {
            switch self {
            case .modal:
                return "modal"
            case .autofill:
                return "autofill"
            }
        }
    }
}
