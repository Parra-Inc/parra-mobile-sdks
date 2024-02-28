//
//  FeedbackCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol FeedbackQuestionViewKind: View {
    associatedtype DataType
    associatedtype AnswerType

    init(
        bucketId: String,
        question: Question,
        data: DataType
    )

    func shouldAllowCommittingSelection() -> Bool
}

extension FeedbackQuestionViewKind {
    func shouldAllowCommittingSelection() -> Bool {
        return true
    }
}

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

    @ViewBuilder var options: some View {
        let palette = themeObserver.theme.palette

        VStack {
            ForEach(data.options) { option in
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

                let attributes = ButtonAttributes(
                    title: LabelAttributes(
                        borderColor: isSelected ? palette.primary
                            .toParraColor() : palette.secondary.toParraColor()
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
    }

    var body: some View {
        options
            .onChange(
                of: contentObserver.currentAnswerState
            ) { _, newValue in
                print("changed to: \(newValue)")
            }
    }

    // MARK: - Private

    private let bucketId: String
    private let question: Question
    private let data: BooleanQuestionBody

    private var currentAnswer: AnswerType? {
        return contentObserver.currentAnswer(for: bucketId)
    }
}

struct FeedbackQuestionCard: View {
    // MARK: - Internal

    let bucketId: String
    let question: Question

    var body: some View {
        switch question.data {
        case .choiceQuestionBody(let choiceQuestionBody):
            Text(choiceQuestionBody.options.description)
        case .checkboxQuestionBody(let checkboxQuestionBody):
            Text(checkboxQuestionBody.options.description)
        case .imageQuestionBody(let imageQuestionBody):
            Text(imageQuestionBody.options.description)
        case .ratingQuestionBody(let ratingQuestionBody):
            Text(ratingQuestionBody.options.description)
        case .starQuestionBody(let starQuestionBody):
            Text(String(describing: starQuestionBody))
        case .shortTextQuestionBody(let shortTextQuestionBody):
            Text(String(describing: shortTextQuestionBody))
        case .longTextQuestionBody(let longTextQuestionBody):
            Text(String(describing: longTextQuestionBody))
        case .booleanQuestionBody(let data):
            composeCard(
                with: FeedbackBooleanQuestionCard.self,
                data: data
            )
        }
    }

    // MARK: - Private

    private func composeCard<T>(
        with type: T.Type,
        data: T.DataType
    ) -> some View where T: FeedbackQuestionViewKind {
        return T(
            bucketId: bucketId,
            question: question,
            data: data
        )
    }
}

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
