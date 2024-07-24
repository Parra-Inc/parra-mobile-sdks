//
//  ParraBooleanKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

// "boolean" means single selection from two options
// This is basically an exact copy of ParraChoiceKindView, but we're making the decision to
// not try to make abstractions and share major elements between question kinds, since the UIs
// for each will likely change.
class ParraBooleanKindView: UIView, ParraQuestionKindView {
    // MARK: - Lifecycle

    required init(
        bucketId: String,
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraCardAnswerHandler
    ) {
        self.question = question
        self.answerHandler = answerHandler
        self.bucketId = bucketId

        super.init(frame: .zero)

        contentContainer.axis = .vertical
        contentContainer.alignment = .fill
        contentContainer.spacing = 8.0
        contentContainer.distribution = .equalCentering
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentContainer)

        generateOptions(
            for: data,
            config: config,
            currentState: answerHandler.currentAnswer(
                for: bucketId
            )
        )

        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            contentContainer.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -8
            ),
            contentContainer.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            contentContainer.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 8
            ),
            contentContainer.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -8
            )
        ])

        applyConfig(config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    typealias DataType = BooleanQuestionBody
    typealias AnswerType = SingleOptionAnswer

    func applyConfig(_ config: ParraCardViewConfig) {
        for optionView in optionViewMap.keys {
            optionView.applyConfig(config)
        }
    }

    // MARK: - Private

    private let contentContainer = UIStackView(frame: .zero)
    private var optionViewMap = [ParraBorderedButton: BooleanQuestionOption]()

    private let question: Question
    private let answerHandler: ParraCardAnswerHandler
    private let bucketId: String

    private func generateOptions(
        for data: DataType,
        config: ParraCardViewConfig,
        currentState: AnswerType?
    ) {
        optionViewMap.removeAll()

        for option in data.options {
            let button = ParraBorderedButton(
                title: option.title,
                optionId: option.id,
                isInitiallySelected: option.id == currentState?.optionId,
                config: config
            )
            button.delegate = self

            optionViewMap[button] = option
            contentContainer.addArrangedSubview(button)
        }
    }
}

// MARK: ParraBorderedButtonDelegate

extension ParraBooleanKindView: ParraBorderedButtonDelegate {
    func buttonShouldSelect(
        button: ParraBorderedButton,
        optionId: String
    ) -> Bool {
        return true
    }

    func buttonDidSelect(
        button: ParraBorderedButton,
        optionId: String
    ) {
        guard let option = optionViewMap[button], option.id == optionId else {
            return
        }

        answerHandler.update(
            answer: QuestionAnswer(
                kind: .radio,
                data: SingleOptionAnswer(optionId: option.id)
            ),
            for: bucketId
        )

        answerHandler.commitAnswers(for: bucketId, question: question)
    }

    func buttonDidDeselect(
        button: ParraBorderedButton,
        optionId: String
    ) {
        answerHandler.update(answer: nil, for: bucketId)

        answerHandler.commitAnswers(for: bucketId, question: question)
    }
}
