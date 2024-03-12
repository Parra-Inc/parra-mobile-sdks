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

    var navigationTitle: String {
        switch self {
        case .pending:
            return "Pending Status"
        case .inProgress:
            return "In progress Status"
        case .live:
            return "Live Status"
        case .rejected:
            return "Rejected Status"
        }
    }

    var explanation: String {
        switch self {
        case .pending:
            return "The ticket is awaiting review, queued for evaluation before any action is taken."
        case .inProgress:
            return "The ticket is currently under review or in the process of being addressed for inclusion in a future update."
        case .live:
            return "The ticket has gone live, indicating that the changes or fixes have been implemented and are now available."
        case .rejected:
            return "The ticket was rejected, meaning that after review, it was decided not to proceed with the proposed changes or fixes."
        }
    }
}
