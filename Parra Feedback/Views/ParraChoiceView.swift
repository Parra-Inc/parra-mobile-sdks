//
//  ParraChoiceView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import UIKit

class ParraChoiceOptionView: UIView {
    let option: ChoiceQuestionOption
    let kind: QuestionKind
    
    private let typeContainerView = UIView(frame: .zero)
    
    required init(option: ChoiceQuestionOption, kind: QuestionKind) {
        self.option = option
        self.kind = kind
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        typeContainerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(typeContainerView)
        
        let optionLabel = UILabel(frame: .zero)
        
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionLabel.text = option.title
        
        addSubview(optionLabel)
        
//        switch type {
//        case .radio:
//            
//        case .checkbox, .dropDown:
//            fatalError("unsupported")
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
