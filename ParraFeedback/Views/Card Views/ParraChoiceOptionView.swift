//
//  ParraChoiceView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import UIKit
import ParraCore

protocol ParraChoiceOptionViewDelegate: NSObjectProtocol {
    func onSelect(option: ChoiceQuestionOption, inView view: ParraChoiceOptionView, fromButton button: SelectableButton)
    func onDeselect(option: ChoiceQuestionOption, inView view: ParraChoiceOptionView, fromButton button: SelectableButton)
}

class ParraChoiceOptionView: UIView {
    let option: ChoiceQuestionOption
    let kind: QuestionKind
    let accessoryButton: UIView & SelectableButton

    weak var delegate: ParraChoiceOptionViewDelegate?
            
    required init(option: ChoiceQuestionOption,
                  kind: QuestionKind,
                  isSelected: Bool) {

        self.option = option
        self.kind = kind
        switch kind {
        case .radio:
            accessoryButton = ParraRadioButton(initiallySelected: isSelected)
        case .checkbox:
            accessoryButton = ParraCheckboxButton(initiallySelected: isSelected)
        case .star:
            accessoryButton = ParraStarButton(initiallySelected: isSelected)
        }
        
        super.init(frame: .zero)
                
        translatesAutoresizingMaskIntoConstraints = false
        
        let optionLabel = UILabel(frame: .zero)
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionLabel.text = option.title
        optionLabel.numberOfLines = 3
        optionLabel.lineBreakMode = .byTruncatingTail
        optionLabel.isUserInteractionEnabled = true
        optionLabel.font = .preferredFont(forTextStyle: .title3)
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureDidPress(gesture:))
        )
        optionLabel.addGestureRecognizer(tapGesture)

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
    
    @objc private func tapGestureDidPress(gesture: UITapGestureRecognizer) {
        accessoryButton.buttonIsSelected = true

        delegate?.onSelect(
            option: option,
            inView: self,
            fromButton: accessoryButton
        )
    }
}

extension ParraChoiceOptionView: SelectableButtonDelegate {
    func buttonDidSelect(button: SelectableButton) {
        delegate?.onSelect(
            option: option,
            inView: self,
            fromButton: button
        )
    }
    
    func buttonDidDeselect(button: SelectableButton) {
        delegate?.onDeselect(
            option: option,
            inView: self,
            fromButton: button
        )
    }
}
