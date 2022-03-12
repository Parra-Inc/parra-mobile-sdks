//
//  ParraQuestionHandler.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

typealias ChoiceSelectionMap = [String: [ChoiceQuestionOption]]

protocol ParraQuestionHandlerDelegate: NSObjectProtocol {
    /// Not meant to be triggered during every selection event. Just when a new selection occurs that may be
    /// required to cause a transition or other side effects.
    func questionHandlerDidMakeNewSelection(forQuestion question: Question)
}

class ParraQuestionHandler: ParraQuestionViewDelegate {
    private var choiceQuestionSelectionMap: ChoiceSelectionMap = [:]
    weak var questionHandlerDelegate: ParraQuestionHandlerDelegate?
    
    required init() {}
    
    // TODO: How will this work for other question types?
    func initialSelection(forQuestion question: Question) -> [ChoiceQuestionOption] {
        return choiceQuestionSelectionMap[question.id] ?? []
    }
    
    func onSelect(option: ChoiceQuestionOption,
                  forQuestion question: Question,
                  inView view: ParraChoiceOptionView,
                  fromButton button: SelectableButton) -> [ChoiceQuestionOption] {
        var existingSelection = choiceQuestionSelectionMap[question.id] ?? []
        if existingSelection.contains(option) {
            return []
        }
        
        var shouldInvokeNewSelectionHandler = false
        defer {
            answerUpdateForQuestion(question: question)
            
            if shouldInvokeNewSelectionHandler {
                // This should only be invoked when a new selection is made, not when it changes
                questionHandlerDelegate?.questionHandlerDidMakeNewSelection(
                    forQuestion: question
                )
            }
        }
        
        if existingSelection.isEmpty || question.kind.allowsMultipleSelection {
            if existingSelection.isEmpty && !question.kind.allowsMultipleSelection {
                // Only invoke new selection handlers for new selection that isn't multi selection.
                // We don't want to navigate was from a multi selector on the first selection.
                shouldInvokeNewSelectionHandler = true
            }

            existingSelection.append(option)
            
            choiceQuestionSelectionMap[question.id] = existingSelection
                        
            return []
        } else {
            choiceQuestionSelectionMap[question.id] = [option]

            return existingSelection
        }
    }
    
    func onDeselect(option: ChoiceQuestionOption,
                    forQuestion question: Question,
                    inView view: ParraChoiceOptionView,
                    fromButton button: SelectableButton) {
        var existingSelection = choiceQuestionSelectionMap[question.id] ?? []
        let existingIndex = existingSelection.firstIndex { $0 == option }
        let hasAlreadyDeselected = existingSelection.isEmpty || existingIndex == nil
        
        if hasAlreadyDeselected {
            return
        }
                
        if question.kind.allowsDeselection {
            existingSelection.remove(at: existingIndex!)
            
            choiceQuestionSelectionMap[question.id] = existingSelection
            
            answerUpdateForQuestion(question: question)
        }
    }
    
    private func answerUpdateForQuestion(question: Question) {
        var completedCard: CompletedCard?

        switch question.data {
        case .choiceQuestionBody(_):
            let selections = choiceQuestionSelectionMap[question.id]
            
            switch question.kind {
            case .radio, .star:
                if let firstSelectedOptionId = selections?.first?.id {
                    completedCard = CompletedCard(
                        id: question.id,
                        data: .question(
                            .choice(
                                .single(
                                    QuestionSingleChoiceCompletedData(
                                        optionId: firstSelectedOptionId
                                    )
                                )
                            )
                        )
                    )
                }
            case .checkbox:
                if let selections = selections {
                    completedCard = CompletedCard(
                        id: question.id,
                        data: .question(
                            .choice(
                                .multiple(
                                    QuestionMultipleChoiceCompletedData(
                                        optionIds: selections.map { $0.id }
                                    )
                                )
                            )
                        )
                    )
                }
            }
        }
        
        guard let completedCard = completedCard else {
            // TODO: Error?
            return
        }
        
        Task {
            await ParraFeedback.shared.dataManager.completeCard(completedCard)
        }
    }
}
