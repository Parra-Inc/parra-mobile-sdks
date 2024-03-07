//
//  FeedbackQuestionViewKind+SingleOptionAnswer.swift
//  Parra
//
//  Created by Mick MacCallum on 2/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackQuestionViewKind where AnswerType == SingleOptionAnswer {
    @ViewBuilder @MainActor
    func buildOption(
        at index: Int,
        id: String,
        title: String
    ) -> some View {
        if index != 0 {
            Spacer(minLength: 4)
                .layoutPriority(2)
        }

        let (content, attributes) = getChoiceContent(
            id: id,
            title: title,
            isSelected: id == currentAnswer?.optionId
        )

        componentFactory.buildTextButton(
            variant: .outlined,
            config: config.choiceOptions,
            content: content,
            suppliedFactory: componentFactory.local?.choiceOptions,
            localAttributes: attributes
        )
        .layoutPriority(100)
    }

    @MainActor
    func getChoiceContent(
        id: String,
        title: String,
        isSelected: Bool
    ) -> (TextButtonContent, TextButtonAttributes) {
        let palette = themeObserver.theme.palette

        let content = TextButtonContent(
            text: LabelContent(text: title),
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
                                optionId: id
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

        let attributes = TextButtonAttributes(
            padding: .zero,
            title: titleAttributes,
            titlePressed: titleAttributes.withUpdates(
                updates: LabelAttributes(
                    fontColor: selectedColor,
                    borderColor: selectedColor
                )
            )
        )

        return (content, attributes)
    }
}
