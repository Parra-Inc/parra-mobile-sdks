//
//  RoadmapWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct TicketContent: Identifiable {
    // MARK: - Lifecycle

    init(
        _ userTicket: UserTicket
    ) {
        self.id = userTicket.id
        self.type = userTicket.type
        self.title = LabelContent(text: userTicket.title)
        self.description = if let description = userTicket.description {
            LabelContent(text: description)
        } else {
            nil
        }
        self.status = userTicket.status
        self.displayStatus = userTicket.displayStatus
        self
            .statusTitle = LabelContent(
                text: userTicket
                    .displayStatusBadgeTitle
            )
        self.votingEnabled = userTicket.votingEnabled
        self.voted = userTicket.voted
        self.voteCount = LabelContent(
            text: userTicket.voteCount.formatted(.number.notation(.compactName))
        )
        self.voteButton = ButtonContent(
            type: .image(.symbol("triangleshape.fill", .monochrome)),
            isDisabled: !votingEnabled,
            onPress: nil
        )
    }

    // MARK: - Internal

    let id: String
    let type: TicketType
    let title: LabelContent
    let description: LabelContent?
    let status: TicketStatus
    let displayStatus: TicketDisplayStatus
    let statusTitle: LabelContent
    let votingEnabled: Bool
    let voted: Bool
    let voteCount: LabelContent
    var voteButton: ButtonContent
}

// MARK: - RoadmapWidget.ContentObserver.Content

extension RoadmapWidget.ContentObserver {
    @MainActor
    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(
            title: String,
            addRequestButton: ButtonContent,
            tickets: [UserTicket]
        ) {
            self.title = LabelContent(text: title)
            self.addRequestButton = addRequestButton
            self.tickets = tickets.map {
                let ticket = TicketContent($0)

//                onUpvote?($0)

                return ticket
            }
        }

        // MARK: - Internal

        let title: LabelContent
        var addRequestButton: ButtonContent
        var onUpvote: ((UserTicket) -> Void)?
        let tickets: [TicketContent]
    }
}
