//
//  RoadmapTicketDisplayStatusBadge.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapTicketDisplayStatusBadge: View {
    // MARK: - Lifecycle

    init(
        displayStatus: TicketDisplayStatus,
        title: String,
        size: Badge.Size = .sm,
        variant: Badge.Variant = .outlined
    ) {
        self.displayStatus = displayStatus
        self.title = title
        self.size = size
        self.variant = variant
    }

    // MARK: - Internal

    let displayStatus: TicketDisplayStatus
    let title: String
    let size: Badge.Size
    let variant: Badge.Variant

    var body: some View {
        Badge(
            size: size,
            variant: variant,
            text: title,
            color: displayStatus.color.toSwatch(),
            icon: .symbol("circle.fill"),
            iconAttributes: nil
        )
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            RoadmapTicketDisplayStatusBadge(
                displayStatus: .pending,
                title: "pending"
            )
            RoadmapTicketDisplayStatusBadge(
                displayStatus: .inProgress,
                title: "in progress"
            )
            RoadmapTicketDisplayStatusBadge(displayStatus: .live, title: "live")
            RoadmapTicketDisplayStatusBadge(
                displayStatus: .rejected,
                title: "rejected"
            )
        }
    }
}
