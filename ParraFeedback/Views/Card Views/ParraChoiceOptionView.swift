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
    internal var config: ParraCardViewConfig {
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
                           config: ParraCardViewConfig,
                           isSelected: Bool) {
        
        self.option = option
        self.kind = kind
        self.config = config
        
        switch kind {
        case .radio:
            accessoryButton = ParraRadioButton(
                initiallySelected: isSelected,
                config: config,
                asset: option.asset
            )
        case .checkbox:
            accessoryButton = ParraCheckboxButton(
                initiallySelected: isSelected,
                config: config,
                asset: option.asset
            )
        case .star:
            accessoryButton = ParraStarButton(
                initiallySelected: isSelected,
                config: config,
                asset: option.asset
            )
        case .image:
            accessoryButton = ParraImageButton(
                initiallySelected: isSelected,
                config: config,
                asset: option.asset
            )
        }
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [accessoryButton])
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let title = option.title {
            optionLabel.translatesAutoresizingMaskIntoConstraints = false
            optionLabel.text = title
            optionLabel.lineBreakMode = .byTruncatingTail
            optionLabel.isUserInteractionEnabled = true
            optionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

            if kind.direction == .vertical {
                optionLabel.numberOfLines = 3
                optionLabel.textAlignment = .left
            } else {
                optionLabel.numberOfLines = 2
                optionLabel.textAlignment = .center
            }

            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(tapGestureDidPress(gesture:))
            )
            optionLabel.addGestureRecognizer(tapGesture)

            stack.addArrangedSubview(optionLabel)
        }

        accessoryButton.delegate = self

        if kind.direction == .vertical {
            stack.axis = .horizontal
            stack.distribution = .fill
            stack.alignment = .center
        } else {
            stack.spacing = 8
            stack.axis = .vertical
            stack.distribution = .fill
            stack.alignment = .fill
        }

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
    
    private func applyConfig(_ config: ParraCardViewConfig) {
        if kind.direction == .vertical {
            optionLabel.font = config.body.font
        } else {
            optionLabel.font = config.bodyBold.font
        }

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
