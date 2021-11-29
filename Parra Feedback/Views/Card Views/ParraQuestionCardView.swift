//
//  ParraCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit

class ParraQuestionCardView: ParraCardView {
    let question: ParraFeedbackQuestion

    private let contentContainer = UIStackView(frame: .zero)
    
    required init(question: ParraFeedbackQuestion) {
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

        
        switch question.type {
        case .choice(let choice):
            generateOptionsForChoice(choice)
        case .form(let form):
            fatalError("form not handled yet. form was: \(form)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func generateOptionsForChoice(_ choice: ParraFeedbackQuestionTypeChoice) {
        for option in choice.options {
            let optionView = ParraChoiceOptionView(
                option: option,
                type: choice.optionType
            )
            
            contentContainer.addArrangedSubview(optionView)
        }
    }
}
