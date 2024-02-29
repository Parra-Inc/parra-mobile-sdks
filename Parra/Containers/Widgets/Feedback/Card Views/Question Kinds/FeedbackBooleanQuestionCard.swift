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
        question: Question,
        data: BooleanQuestionBody
    ) {
        self.bucketId = bucketId
        self.question = question
        self.data = data
    }

    // MARK: - Internal

    typealias AnswerType = SingleOptionAnswer

    @Environment(FeedbackCardWidgetConfig.self) var config
    @EnvironmentObject var componentFactory: ComponentFactory<
        FeedbackCardWidgetFactory
    >
    @EnvironmentObject var themeObserver: ParraThemeObserver
    @EnvironmentObject var contentObserver: FeedbackCardWidget.ContentObserver

    @ViewBuilder var body: some View {
        VStack(spacing: 12) {
            ForEach(data.options) { option in
                renderOption(option)
            }
        }
    }

    // MARK: - Private

    private let bucketId: String
    private let question: Question
    private let data: BooleanQuestionBody

    private var currentAnswer: AnswerType? {
        return contentObserver.currentAnswer(for: bucketId)
    }

    @ViewBuilder
    private func renderOption(_ option: BooleanQuestionOption) -> some View {
        let palette = themeObserver.theme.palette
        let isSelected = option.id == currentAnswer?.optionId

        let content = ButtonContent(
            type: ButtonContent.ContentType.text(
                LabelContent(text: option.title)
            ),
            isDisabled: false,
            onPress: {
                if isSelected {
                    contentObserver.update(
                        answer: nil,
                        for: bucketId
                    )
                } else {
                    contentObserver.update(
                        answer: QuestionAnswer(
                            kind: .boolean,
                            data: SingleOptionAnswer(
                                optionId: option.id
                            )
                        ),
                        for: bucketId
                    )
                }

                contentObserver.commitAnswers(
                    for: bucketId,
                    question: question
                )
            }
        )

        let selectedColor = palette.primary.toParraColor()

        let fontColor = isSelected ? selectedColor : palette.primaryText
            .toParraColor()

        let borderColor = isSelected ? selectedColor : palette
            .secondarySeparator.toParraColor()

        let titleAttributes = LabelAttributes(
            font: Font.system(.body),
            fontColor: fontColor,
            borderColor: borderColor
        )

        let attributes = ButtonAttributes(
            title: titleAttributes,
            titlePressed: titleAttributes.withUpdates(
                updates: LabelAttributes(
                    fontColor: selectedColor,
                    borderColor: selectedColor
                )
            )
        )

        componentFactory.buildButton(
            variant: .outlined,
            component: \.booleanOptions,
            config: config.booleanOptions,
            content: content,
            localAttributes: attributes
        )
    }
}

#Preview {
    ParraCardViewPreview {
        FeedbackBooleanQuestionCard(
            bucketId: UUID().uuidString,
            question: ParraCardItemFixtures.boolQuestion,
            data: ParraCardItemFixtures.boolQuestionData
        )
    }
}
