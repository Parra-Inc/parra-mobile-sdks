//
//  ParraQuestionHandler.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

typealias ChoiceSelectionMap = [String: [ChoiceQuestionOption]]

class ParraQuestionHandler: ParraQuestionViewDelegate {
    private var choiceQuestionSelectionMap: ChoiceSelectionMap = [:]
    
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
        let hasAlreadySelected = !existingSelection.isEmpty &&
            existingSelection.contains(option)
        
        if hasAlreadySelected {
            return []
        }
        
        defer {
            answerUpdateForQuestion(question: question)
        }
        
        if existingSelection.isEmpty || question.kind.allowsMultipleSelection {
            
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
