//
//  ParraCardAnswerHandler.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

// 1. Must support state changes from every "kind" of question.
// 2. Must cache state updates (persist them to disk???)
// 3. Must support being told to commit changes. Changes shouldn't be uploaded until commited.
// 4. Must invoke dataManager.completeCard(completedCard)

/// Maps a question id to an answer for that question
typealias AnswerStateMap = [String: QuestionAnswer]

protocol ParraQuestionHandlerDelegate: AnyObject {
    /// Not meant to be triggered during every selection event. Just when a new selection occurs that may be
    /// required to cause a transition or other side effects.
    func questionHandlerDidMakeNewSelection(
        forQuestion question: Question
    ) async
}

protocol ParraAnswerHandler {
    func initialState<T: AnswerOption>(
        for bucketItemId: String
    ) -> T?

    func update(
        answer: QuestionAnswer?,
        for bucketItemId: String
    )

    func commitAnswers(
        for bucketItemId: String,
        question: Question
    )
}

class ParraCardAnswerHandler: ParraAnswerHandler {
    // MARK: Lifecycle

    required init() {}

    // MARK: Internal

    weak var questionHandlerDelegate: ParraQuestionHandlerDelegate?

    func initialState<T: AnswerOption>(
        for bucketItemId: String
    ) -> T? {
        guard let value = currentAnswerState[bucketItemId] else {
            return nil
        }

        return value.data as? T
    }

    func update(
        answer: QuestionAnswer?,
        for bucketItemId: String
    ) {
        currentAnswerState[bucketItemId] = answer
    }

    func commitAnswers(
        for bucketItemId: String,
        question: Question
    ) {
        guard let answer = currentAnswerState[bucketItemId] else {
            // This check is critical since it's possible that a card could commit a selection change
            // without any answers selected.
            return
        }

        let completedCard = CompletedCard(
            bucketItemId: bucketItemId,
            questionId: question.id,
            data: answer
        )

        Task {
            await ParraFeedback.shared.dataManager.completeCard(completedCard)

            // This should only be invoked when a new selection is made, not when it changes
            await questionHandlerDelegate?.questionHandlerDidMakeNewSelection(
                forQuestion: question
            )
        }
    }

    // MARK: Private

    private var currentAnswerState: AnswerStateMap = [:]
}
