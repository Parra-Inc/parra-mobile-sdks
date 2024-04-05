//
//  FeedbackCheckboxQuestionCard.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackCheckboxQuestionCard: FeedbackQuestionViewKind {
    // MARK: - Lifecycle

    init(
        bucketId: String,
        question: Question,
        data: CheckboxQuestionBody
    ) {
        self.bucketId = bucketId
        self.question = question
        self.data = data
    }

    // MARK: - Internal

    typealias AnswerType = MultiOptionAnswer

    @Environment(FeedbackCardWidgetConfig.self) var config
    @Environment(FeedbackCardWidgetBuilderConfig.self) var localBuilderConfig
    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver
    @EnvironmentObject var contentObserver: FeedbackCardWidget.ContentObserver

    let bucketId: String
    let question: Question
    let data: CheckboxQuestionBody

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
}

#Preview {
    ParraCardViewPreview {
        FeedbackCheckboxQuestionCard(
            bucketId: ParraCardItemFixtures.choiceBucketId,
            question: ParraCardItemFixtures.checkboxQuestion,
            data: ParraCardItemFixtures.checkboxQuestionData
        )
    }
}
