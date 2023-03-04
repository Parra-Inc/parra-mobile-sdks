//
//  ParraCardAnswerHandler.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation
import ParraCore

// 1. Must support state changes from every "kind" of question.
// 2. Must cache state updates (persist them to disk???)
// 3. Must support being told to commit changes. Changes shouldn't be uploaded until commited.
// 4. Must invoke dataManager.completeCard(completedCard)

/// Maps a question id to an answer for that question
typealias AnswerStateMap = [String: QuestionAnswer]

protocol ParraQuestionHandlerDelegate: AnyObject {
    /// Not meant to be triggered during every selection event. Just when a new selection occurs that may be
    /// required to cause a transition or other side effects.
    func questionHandlerDidMakeNewSelection(forQuestion question: Question)
}

protocol ParraAnswerHandler {
    func initialState<T: AnswerOption>(
        for question: Question
    ) -> T?

    func update(
        answer: QuestionAnswer?,
        for question: Question
    )

    func commitAnswers(for question: Question)
}

class ParraCardAnswerHandler: ParraAnswerHandler {
    private var currentAnswerState: AnswerStateMap = [:]
    weak var questionHandlerDelegate: ParraQuestionHandlerDelegate?
    
    required init() {}

    func initialState<T: AnswerOption>(
        for question: Question
    ) -> T? {
        guard let value = currentAnswerState[question.id] else {
            return nil
        }

        return value.data as? T
    }

    func update(
        answer: QuestionAnswer?,
        for question: Question
    ) {
        currentAnswerState[question.id] = answer
    }

    func commitAnswers(for question: Question) {
        guard let answer = currentAnswerState[question.id] else {
            // This check is critical since it's possible that a card could commit a selection change
            // without any answers selected.
            return
        }

        let completedCard = CompletedCard(
            questionId: question.id,
            data: answer
        )

        Task {
            await ParraFeedback.shared.dataManager.completeCard(completedCard)
        }

        // This should only be invoked when a new selection is made, not when it changes
        questionHandlerDelegate?.questionHandlerDidMakeNewSelection(
            forQuestion: question
        )
    }
}
