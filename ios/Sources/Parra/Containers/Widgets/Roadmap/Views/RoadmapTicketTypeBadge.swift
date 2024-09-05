//
//  RoadmapTicketTypeBadge.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapTicketTypeBadge: View {
    // MARK: - Lifecycle

    init(
        type: ParraTicketType,
        size: ParraBadgeSize = .sm,
        variant: ParraBadgeVariant = .outlined,
        educationAlerts: Bool = false
    ) {
        self.type = type
        self.size = size
        self.variant = variant
        self.educationAlerts = educationAlerts
    }

    // MARK: - Internal

    let type: ParraTicketType
    let size: ParraBadgeSize
    let variant: ParraBadgeVariant

    var body: some View {
        componentFactory.buildBadge(
            size: size,
            variant: variant,
            text: type.title,
            swatch: type.backgroundColor.toSwatch(),
            iconSymbol: "circle.fill"
        )
        .onTapGesture {
            isAlertPresented = true
        }
        .allowsHitTesting(educationAlerts)
        .alert(type.navigationTitle, isPresented: $isAlertPresented, actions: {
            EmptyView()
        }, message: {
            Text(type.explanation)
        })
    }

    // MARK: - Private

    @State private var isAlertPresented = false
    private let educationAlerts: Bool

    @Environment(ComponentFactory.self) private var componentFactory
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            RoadmapTicketTypeBadge(type: .bug)
            RoadmapTicketTypeBadge(type: .feature)
            RoadmapTicketTypeBadge(type: .improvement)
        }
    }
}
