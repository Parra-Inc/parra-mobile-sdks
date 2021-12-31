//
//  ParraChoiceView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import UIKit

protocol ParraChoiceOptionViewDelegate: NSObjectProtocol {
    func onSelect(option: ChoiceQuestionOption, view: ParraChoiceOptionView, button: SelectableButton)
    func onDeselect(option: ChoiceQuestionOption, view: ParraChoiceOptionView, button: SelectableButton)
}

class ParraChoiceOptionView: UIView {
    let option: ChoiceQuestionOption
    let kind: QuestionKind
    weak var delegate: ParraChoiceOptionViewDelegate?
            
    required init(option: ChoiceQuestionOption, kind: QuestionKind) {
        self.option = option
        self.kind = kind
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
                
        let optionLabel = UILabel(frame: .zero)
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionLabel.text = option.title
        optionLabel.numberOfLines = 3
        optionLabel.lineBreakMode = .byTruncatingTail

        let accessoryButton: UIView & SelectableButton
        
        switch kind {
        case .radio:
            accessoryButton = ParraRadioButton()
        case .checkbox:
            accessoryButton = ParraCheckboxButton()
        }

        accessoryButton.delegate = self

        let stack = UIStackView(arrangedSubviews: [accessoryButton, optionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center

        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ParraChoiceOptionView: SelectableButtonDelegate {
    func buttonDidSelect(button: SelectableButton) {
        delegate?.onSelect(option: option, view: self, button: button)
    }
    
    func buttonDidDeselect(button: SelectableButton) {
        delegate?.onDeselect(option: option, view: self, button: button)
    }
}
