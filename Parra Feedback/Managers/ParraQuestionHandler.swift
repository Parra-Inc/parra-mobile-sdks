//
//  ParraQuestionHandler.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

typealias ChoiceSelectionMap = [String: [ChoiceQuestionOption]]

protocol ParraQuestionHandlerDelegate: NSObjectProtocol {
    // should probably post updates to data storage when data changes. This might
    // be better if ParraQuestionHandler was a superclass or if we provide default
    // implementations of whatever methods are declared here.
    
    func updateAnswer(forQuestion question: Question, answer: Answer)
}

class ParraQuestionHandler: ParraQuestionViewDelegate {
    var questionDelegate: ParraQuestionHandlerDelegate?
    
    // TODO: Does this need to be built up before being modified?
    // TODO: This also needs to provide a way to get the stored data out to determine initial selection state of buttons.
    private var selectionMap: ChoiceSelectionMap  = [:] {
        didSet {
            print("selection map: \(selectionMap)")
        }
    }
    
    required init() {

    }
    
    func initialSelection(forQuestion question: Question) -> [ChoiceQuestionOption] {
        return selectionMap[question.id] ?? []
    }
    
    func onSelect(option: ChoiceQuestionOption,
                  forQuestion question: Question,
                  inView view: ParraChoiceOptionView,
                  fromButton button: SelectableButton) -> [ChoiceQuestionOption] {
        var existingSelection = selectionMap[question.id] ?? []
        let hasAlreadySelected = !existingSelection.isEmpty &&
            existingSelection.contains(option)
        
        if hasAlreadySelected {
            return []
        }
        
        if existingSelection.isEmpty || question.kind.allowsMultipleSelection {
            
            existingSelection.append(option)
            
            selectionMap[question.id] = existingSelection
            
            return []
        } else {
            selectionMap[question.id] = [option]

            return existingSelection
        }
    }
    
    func onDeselect(option: ChoiceQuestionOption,
                    forQuestion question: Question,
                    inView view: ParraChoiceOptionView,
                    fromButton button: SelectableButton) {
        var existingSelection = selectionMap[question.id] ?? []
        let existingIndex = existingSelection.firstIndex { $0 == option }
        let hasAlreadyDeselected = existingSelection.isEmpty || existingIndex == nil
        
        if hasAlreadyDeselected {
            return
        }
        
        if question.kind.allowsDeselection {
            existingSelection.remove(at: existingIndex!)
            
            selectionMap[question.id] = existingSelection
        }
    }
}
