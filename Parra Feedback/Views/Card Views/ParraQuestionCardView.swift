//
//  ParraCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit

protocol ParraQuestionViewDelegate {
    func onSelect(option: ChoiceQuestionOption, forQuestion question: Question, inView view: ParraChoiceOptionView, fromButton button: SelectableButton)
    func onDeselect(option: ChoiceQuestionOption, forQuestion question: Question, inView view: ParraChoiceOptionView, fromButton button: SelectableButton)
}

class ParraQuestionCardView: ParraCardView {
    let question: Question
    let questionHandler: ParraQuestionHandler

    private let contentContainer = UIStackView(frame: .zero)
    
    required init(question: Question, questionHandler: ParraQuestionHandler) {
        self.question = question
        self.questionHandler = questionHandler
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.axis = .vertical
        contentContainer.alignment = .fill
        contentContainer.distribution = .equalSpacing

        addSubview(contentContainer)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            contentContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
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
                contentContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12)
            ])
        } else {
            NSLayoutConstraint.activate([
                contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
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
        for option in choice.options {
            let optionView = ParraChoiceOptionView(
                option: option,
                kind: question.kind
            )
            optionView.delegate = self

            contentContainer.addArrangedSubview(optionView)
        }
    }
}

extension ParraQuestionCardView: ParraChoiceOptionViewDelegate {
    func onSelect(option: ChoiceQuestionOption,
                  inView view: ParraChoiceOptionView,
                  fromButton button: SelectableButton) {
        questionHandler.onSelect(
            option: option,
            forQuestion: question,
            inView: view,
            fromButton: button
        )
    }
    
    func onDeselect(option: ChoiceQuestionOption,
                    inView view: ParraChoiceOptionView,
                    fromButton button: SelectableButton) {
        questionHandler.onDeselect(
            option: option,
            forQuestion: question,
            inView: view,
            fromButton: button
        )
    }
}
