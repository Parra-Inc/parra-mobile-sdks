//
//  FeedbackQuestionViewKind+MultiOptionAnswer.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackQuestionViewKind where AnswerType == MultiOptionAnswer {
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

        let isSelected = currentAnswer?.options.contains {
            $0.id == id
        } ?? false

        let (content, attributes) = getChoiceContent(
            id: id,
            title: title,
            isSelected: isSelected
        )

        componentFactory.buildTextButton(
            variant: .outlined,
            config: config.checkboxOptions,
            content: content,
            suppliedBuilder: localBuilderConfig.checkboxOptions,
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
                var currentOptions = (currentAnswer?.options ?? []).map(\.id)

                if !isSelected, !currentOptions.contains(id) {
                    currentOptions.append(id)
                } else if isSelected, currentOptions.contains(id) {
                    currentOptions.removeAll { $0 == id }
                } else {
                    return
                }

                let answer: QuestionAnswer? = if currentOptions.isEmpty {
                    nil
                } else {
                    QuestionAnswer(
                        kind: .checkbox,
                        data: MultiOptionAnswer(
                            options: currentOptions.map {
                                MultiOptionIndividualOption(id: $0)
                            }
                        )
                    )
                }

                contentObserver.update(
                    answer: answer,
                    for: bucketId
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
