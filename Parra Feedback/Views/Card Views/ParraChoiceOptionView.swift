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

        let accessoryButton: UIView & SelectableButton
        
        accessoryButton = ParraRadioButton()
        accessoryButton.delegate = self
        
//        switch kind {
//        case .radio:
//            let radio = RadioButton(frame: .zero)
//            radio.radioCircle = RadioButtonCircleStyle(outerCircle: <#T##CGFloat#>, innerCircle: <#T##CGFloat#>, outerCircleBorder: <#T##CGFloat#>, contentPadding: <#T##CGFloat#>)
//            radio.delegate = self
//            self.accessoryButton = radio
//        case .checkbox:
//            let checkbox = CheckboxButton(frame: .zero)
//            checkbox.delegate = self
//            self.accessoryButton = checkbox
//        }

        let stack = UIStackView(arrangedSubviews: [accessoryButton, optionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill

        typeContainerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: typeContainerView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: typeContainerView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: typeContainerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: typeContainerView.trailingAnchor)
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
