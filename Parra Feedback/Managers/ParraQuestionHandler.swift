//
//  ParraQuestionHandler.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

typealias ChoiceSelectionMap = [String: [(option: ChoiceQuestionOption, button: SelectableButton)]]

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
    
    func onSelect(option: ChoiceQuestionOption,
                  forQuestion question: Question,
                  inView view: ParraChoiceOptionView,
                  fromButton button: SelectableButton) {
        var existingSelection = selectionMap[question.id] ?? []
        let hasAlreadySelected = !existingSelection.isEmpty &&
            existingSelection.contains { $0.option == option }
        
        if hasAlreadySelected {
            return
        }
        
        if existingSelection.isEmpty || question.kind.allowsMultipleSelection {
            
            existingSelection.append((option, button))
            
            selectionMap[question.id] = existingSelection
        } else {
            for selectedOption in existingSelection {
                selectedOption.button.buttonIsSelected = false
            }
            
            selectionMap[question.id] = [(option, button)]
        }
    }
    
    func onDeselect(option: ChoiceQuestionOption,
                    forQuestion question: Question,
                    inView view: ParraChoiceOptionView,
                    fromButton button: SelectableButton) {
        var existingSelection = selectionMap[question.id] ?? []
        let existingIndex = existingSelection.firstIndex { $0.option == option }
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
