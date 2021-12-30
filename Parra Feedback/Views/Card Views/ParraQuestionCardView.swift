//
//  ParraCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import MBRadioCheckboxButton

class ParraQuestionCardView: ParraCardView {
    let question: Question

    private let contentContainer = UIStackView(frame: .zero)
    
    required init(question: Question) {
        self.question = question
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.axis = .vertical
        contentContainer.alignment = .fill
        contentContainer.distribution = .equalSpacing

        addSubview(contentContainer)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
        
        let titleLabel = UILabel(frame: .zero)
        
        titleLabel.text = question.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        if let subtitle = question.subtitle {
            let subtitleLabel = UILabel(frame: .zero)
            
            subtitleLabel.text = subtitle
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.numberOfLines = 0
            subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption2)

            addSubview(subtitleLabel)
            
            NSLayoutConstraint.activate([
                subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
            ])
            
            NSLayoutConstraint.activate([
                contentContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)
            ])
        }

        switch question.data {
        case .choiceQuestionBody(let choice):
            generateOptionsForChoice(choice)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func generateOptionsForChoice(_ choice: ChoiceQuestionBody) {
        switch question.kind {
        case .checkbox:
            let container = CheckboxButtonContainer()
        case .radio:
            let container = RadioButtonContainer()
            
            for option in choice.options {
                let optionView = ParraChoiceOptionView(
                    option: option,
                    kind: question.kind
                )
                optionView.delegate = self
                                
//                container.addButtons([optionView.accessoryButton as! RadioButton])
                
                contentContainer.addArrangedSubview(optionView)
            }
        }
    }
}

extension ParraQuestionCardView: ParraChoiceOptionViewDelegate {
    func onSelect(option: ChoiceQuestionOption, view: ParraChoiceOptionView, button: SelectableButton) {
        print("selected: \(option)")
    }
    
    func onDeselect(option: ChoiceQuestionOption, view: ParraChoiceOptionView, button: SelectableButton) {
        print("deselected: \(option)")
    }
}
