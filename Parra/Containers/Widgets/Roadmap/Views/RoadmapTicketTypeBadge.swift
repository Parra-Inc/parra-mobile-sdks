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
        variant: Badge.Variant = .outlined,
        educationAlerts: Bool = false
    ) {
        self.type = type
        self.size = size
        self.variant = variant
        self.educationAlerts = educationAlerts
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
        .contentShape(.rect)
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
