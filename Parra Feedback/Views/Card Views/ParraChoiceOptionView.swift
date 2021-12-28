//
//  ParraChoiceView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import UIKit
import MBRadioCheckboxButton

protocol ParraChoiceOptionViewDelegate: NSObjectProtocol {
    func onSelect(option: ChoiceQuestionOption, view: ParraChoiceOptionView)
    func onDeselect(option: ChoiceQuestionOption, view: ParraChoiceOptionView)
}

class ParraChoiceOptionView: UIView {
    let option: ChoiceQuestionOption
    let kind: QuestionKind
    weak var delegate: ParraChoiceOptionViewDelegate?
    
    private let typeContainerView = UIView(frame: .zero)
    
    required init(option: ChoiceQuestionOption, kind: QuestionKind) {
        self.option = option
        self.kind = kind
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        typeContainerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(typeContainerView)
        
        NSLayoutConstraint.activate([
            typeContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            typeContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            typeContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            typeContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        
        let optionLabel = UILabel(frame: .zero)
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionLabel.text = option.title
        
        let accessoryButton: RadioCheckboxBaseButton?
        switch kind {
        case .radio:
            let radio = RadioButton(frame: .zero)
            radio.delegate = self
            accessoryButton = radio
        case .checkbox:
            let checkbox = CheckboxButton(frame: .zero)
            checkbox.delegate = self
            accessoryButton = checkbox
        }
        
        var arrangedSubviews: [UIView] = [optionLabel]
        
        if let accessoryButton = accessoryButton {
            arrangedSubviews.insert(accessoryButton, at: 0)
            accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        }
                
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center

        typeContainerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: typeContainerView.topAnchor, constant: 0),
            stack.bottomAnchor.constraint(equalTo: typeContainerView.bottomAnchor, constant: 0),
            stack.leadingAnchor.constraint(equalTo: typeContainerView.leadingAnchor, constant: 0),
            stack.trailingAnchor.constraint(equalTo: typeContainerView.trailingAnchor, constant: 0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ParraChoiceOptionView: CheckboxButtonDelegate {
    func chechboxButtonDidSelect(_ button: CheckboxButton) {
        delegate?.onSelect(option: option, view: self)
    }
    
    func chechboxButtonDidDeselect(_ button: CheckboxButton) {
        delegate?.onDeselect(option: option, view: self)
    }
}

extension ParraChoiceOptionView: RadioButtonDelegate {
    func radioButtonDidSelect(_ button: RadioButton) {
        delegate?.onSelect(option: option, view: self)
    }
    
    func radioButtonDidDeselect(_ button: RadioButton) {
        delegate?.onDeselect(option: option, view: self)
    }
}
