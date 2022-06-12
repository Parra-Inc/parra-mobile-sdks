//
//  ParraChoiceView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import UIKit
import ParraCore

internal protocol ParraChoiceOptionViewDelegate: AnyObject {
    func onSelect(option: ChoiceQuestionOption, inView view: ParraChoiceOptionView, fromButton button: SelectableButton)
    func onDeselect(option: ChoiceQuestionOption, inView view: ParraChoiceOptionView, fromButton button: SelectableButton)
}

internal class ParraChoiceOptionView: UIView {
    internal var config: ParraFeedbackViewConfig {
        didSet {
            applyConfig(config)
        }
    }
    
    private let option: ChoiceQuestionOption
    private let kind: QuestionKind
    private let optionLabel = UILabel(frame: .zero)
    
    internal let accessoryButton: UIView & SelectableButton
    internal weak var delegate: ParraChoiceOptionViewDelegate?
    
    internal required init(option: ChoiceQuestionOption,
                           kind: QuestionKind,
                           config: ParraFeedbackViewConfig,
                           isSelected: Bool) {
        
        self.option = option
        self.kind = kind
        self.config = config
        
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
        
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionLabel.text = option.title
        optionLabel.numberOfLines = 3
        optionLabel.lineBreakMode = .byTruncatingTail
        optionLabel.isUserInteractionEnabled = true
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
        
        applyConfig(config)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConfig(_ config: ParraFeedbackViewConfig) {
        optionLabel.font = config.body.font
        optionLabel.textColor = config.body.color
        optionLabel.layer.shadowColor = config.body.shadow.color.cgColor
        optionLabel.layer.shadowOpacity = config.body.shadow.opacity
        optionLabel.layer.shadowRadius = config.body.shadow.radius
        optionLabel.layer.shadowOffset = config.body.shadow.offset
        
        accessoryButton.tintColor = config.tintColor
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
