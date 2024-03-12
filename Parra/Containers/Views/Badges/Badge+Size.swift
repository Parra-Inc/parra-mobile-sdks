//
//  Badge+Size.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension Badge {
    enum Size {
        case sm
        case md

        // MARK: - Internal

        var padding: EdgeInsets {
            switch self {
            case .sm:
                return EdgeInsets(vertical: 2, horizontal: 6)
            case .md:
                return EdgeInsets(vertical: 4, horizontal: 8)
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .sm:
                return 9
            case .md:
                return 14
            }
        }

        var fontWeight: Font.Weight {
            return .medium
        }

        var cornerRadius: ParraCornerRadiusSize {
            return .sm
        }
    }
}
