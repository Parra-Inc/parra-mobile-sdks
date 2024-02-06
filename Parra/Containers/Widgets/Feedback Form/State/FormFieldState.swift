//
//  FormFieldState.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

internal enum FormFieldState {
    case valid
    case invalid(String)

    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let error):
            return error
        }
    }
}
