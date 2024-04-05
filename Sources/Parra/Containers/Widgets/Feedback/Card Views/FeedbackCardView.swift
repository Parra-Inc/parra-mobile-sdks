//
//  FeedbackCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackCardView: View {
    // MARK: - Lifecycle

    init(
        cardItem: ParraCardItem,
        contentPadding: EdgeInsets
    ) {
        self.cardItem = cardItem
        self.contentPadding = contentPadding
    }

    // MARK: - Public

    public var body: some View {
        card
            .padding(.horizontal, from: contentPadding)
    }

    // MARK: - Internal

    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver

    let cardItem: ParraCardItem
    let contentPadding: EdgeInsets

    // MARK: - Private

    private var card: some View {
        switch cardItem.data {
        case .question(let question):
            FeedbackQuestionCard(
                bucketId: cardItem.id,
                question: question
            )
        }
    }
}

#Preview {
    ParraCardViewPreview {
        FeedbackCardView(
            cardItem: ParraCardItemFixtures.boolCard,
            contentPadding: FeedbackCardWidgetStyle.default(
                with: .default
            )
            .contentPadding
        )
    }
}
