//
//  ParraComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public enum ParraComponentType: Hashable {
    case view

    case label

    case button // todo
    
    case plainButton
    case outlinedButton
    case containedButton

    internal init(for buttonVariant: ParraButtonVariant) {
        switch buttonVariant {
        case .plain:
            self = .plainButton
        case .outlined:
            self = .outlinedButton
        case .contained:
            self = .containedButton
        }
    }
}
