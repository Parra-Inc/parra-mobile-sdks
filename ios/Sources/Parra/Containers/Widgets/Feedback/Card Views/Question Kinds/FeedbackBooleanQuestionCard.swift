//
//  FeedbackBooleanQuestionCard.swift
//  Parra
//
//  Created by Mick MacCallum on 2/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackBooleanQuestionCard: FeedbackQuestionViewKind {
    // MARK: - Lifecycle

    init(
        bucketId: String,
        question: ParraQuestion,
        data: ParraBooleanQuestionBody
    ) {
        self.bucketId = bucketId
        self.question = question
        self.data = data
    }

    // MARK: - Internal

    typealias AnswerType = SingleOptionAnswer

    @Environment(ParraFeedbackCardWidgetConfig.self) var config
    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var contentObserver: FeedbackCardWidget.ContentObserver

    let bucketId: String
    let question: ParraQuestion
    let data: ParraBooleanQuestionBody

    @ViewBuilder var body: some View {
        VStack(spacing: 0) {
            ForEach(data.options.indices, id: \.self) { index in
                let option = data.options[index]

                buildOption(
                    at: index,
                    id: option.id,
                    title: option.title
                )
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraCardViewPreview {
        FeedbackBooleanQuestionCard(
            bucketId: ParraCardItemFixtures.boolBucketId,
            question: ParraCardItemFixtures.boolQuestion,
            data: ParraCardItemFixtures.boolQuestionData
        )
    }
}
