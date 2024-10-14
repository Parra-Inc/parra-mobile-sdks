//
//  ParraPaddingSize.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraPaddingSize: Hashable, Equatable {
    case zero
    case xs
    case sm
    case md
    case lg
    case xl
    case xxl
    case xxxl
    case custom(EdgeInsets)

    // MARK: - Public

    public func hash(into hasher: inout Hasher) {
        let stringValue = switch self {
        case .zero:
            "0"
        case .xs:
            "xs"
        case .sm:
            "xs"
        case .md:
            "xs"
        case .lg:
            "xs"
        case .xl:
            "xs"
        case .xxl:
            "xs"
        case .xxxl:
            "xs"
        case .custom(let edgeInsets):
            "top:\(edgeInsets.bottom), bottom:\(edgeInsets.bottom), leading:\(edgeInsets.leading), trailing:\(edgeInsets.trailing)"
        }

        hasher.combine(stringValue)
    }
}
