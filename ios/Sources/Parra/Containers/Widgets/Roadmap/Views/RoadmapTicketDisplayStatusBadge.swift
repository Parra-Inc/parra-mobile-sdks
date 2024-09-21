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
        displayStatus: ParraTicketDisplayStatus,
        title: String,
        size: ParraBadgeSize = .sm,
        variant: ParraBadgeVariant = .outlined,
        educationAlerts: Bool = false
    ) {
        self.displayStatus = displayStatus
        self.title = title
        self.size = size
        self.variant = variant
        self.educationAlerts = educationAlerts
    }

    // MARK: - Internal

    let displayStatus: ParraTicketDisplayStatus
    let title: String
    let size: ParraBadgeSize
    let variant: ParraBadgeVariant

    var body: some View {
        componentFactory.buildBadge(
            size: size,
            variant: variant,
            text: title,
            swatch: displayStatus.color.toSwatch(),
            iconSymbol: "circle.fill"
        )
        .onTapGesture {
            isAlertPresented = true
        }
        .allowsHitTesting(educationAlerts)
        .alert(
            displayStatus.navigationTitle,
            isPresented: $isAlertPresented,
            actions: {
                EmptyView()
            },
            message: {
                Text(displayStatus.explanation)
            }
        )
    }

    // MARK: - Private

    @State private var isAlertPresented = false
    private let educationAlerts: Bool

    @Environment(\.parraComponentFactory) private var componentFactory
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
