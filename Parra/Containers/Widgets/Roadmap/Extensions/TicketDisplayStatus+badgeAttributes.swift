//
//  TicketDisplayStatus+badgeAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension TicketDisplayStatus {
    var color: Color {
        switch self {
        case .pending:
            return ParraColorSwatch.gray.shade500
        case .inProgress:
            return ParraColorSwatch.blue.shade500
        case .live:
            return ParraColorSwatch.green.shade500
        case .rejected:
            return ParraColorSwatch.red.shade500
        }
    }
}
