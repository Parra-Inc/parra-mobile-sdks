//
//  FeedbackCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraFeedbackCardView: View {
    // MARK: - Lifecycle

    public init(cards: [ParraCardItem]) {}

    // MARK: - Public

    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ParraViewPreview {
        ParraFeedbackCardView(
            cards: ParraCardItem.validStates()
        )
    }
}
