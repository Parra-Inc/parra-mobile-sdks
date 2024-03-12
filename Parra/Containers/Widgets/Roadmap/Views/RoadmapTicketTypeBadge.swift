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
        type: TicketType,
        size: Badge.Size = .sm,
        variant: Badge.Variant = .outlined
    ) {
        self.type = type
        self.size = size
        self.variant = variant
    }

    // MARK: - Internal

    let type: TicketType
    let size: Badge.Size
    let variant: Badge.Variant

    var body: some View {
        Badge(
            size: size,
            variant: variant,
            text: type.title,
            color: type.backgroundColor.toSwatch(),
            icon: .symbol("circle.fill"),
            iconAttributes: nil
        )
    }
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
