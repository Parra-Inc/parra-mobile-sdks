//
//  ParraLongTextKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/12/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraLongTextKindView: UIView, ParraQuestionKindView {
    typealias DataType = LongTextQuestionBody
    typealias AnswerType = TextValueAnswer

    private let answerHandler: ParraAnswerHandler
    private let textView: ParraBorderedTextView
    private let question: Question
    private let data: DataType
    private var validationError = TextValidationError.none
    private let validationLabel = UILabel(frame: .zero)

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.answerHandler = answerHandler
        self.question = question
        self.data = data
        self.textView = ParraBorderedTextView(config: config)

        super.init(frame: .zero)

        textView.placeholder = data.placeholder

        setup()
        applyConfig(config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.returnKeyType = .default
        textView.enablesReturnKeyAutomatically = true
        textView.keyboardType = .asciiCapable
        textView.autocorrectionType = .yes
        textView.autocapitalizationType = .sentences
        textView.spellCheckingType = .yes

        addSubview(textView)

        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.textAlignment = .right
        validationLabel.textColor = Parra.Constant.brandColor

        addSubview(validationLabel)

        textView.activateEdgeConstraintsWithVerticalCenteringPreference(
            to: self,
            with: UIEdgeInsets(
                top: 12,
                left: 8,
                bottom: 12,
                right: 8
            )
        )
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: 120),
            validationLabel.topAnchor.constraint(
                equalTo: textView.bottomAnchor,
                constant: 4
            ),
            validationLabel.trailingAnchor.constraint(
                equalTo: textView.trailingAnchor,
                constant: -4
            ),
        ])
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        textView.applyConfig(config)
        validationLabel.font = config.label.font
    }

    func shouldAllowCommittingSelection() -> Bool {
        return validationError == .none
    }

    private func validateText(text: String) -> TextValidationError {
        let minLength = data.minLength
        let maxLength = data.maxLength
        let textLength = text.trimmingCharacters(in: .whitespacesAndNewlines).count

        if textLength > maxLength {
            return .maximum
        } else if textLength < minLength {
            return .minimum
        } else {
            return .none
        }
    }

    private func updateValidation(text: String) {
        validationError = validateText(text: text)

        switch validationError {
        case .none:
            validationLabel.text = nil
        case .minimum:
            let chars = data.minLength.simplePluralized(singularString: "character")
            validationLabel.text = "must have at least \(data.minLength) \(chars)"
        case .maximum:
            let chars = data.maxLength.simplePluralized(singularString: "character")
            validationLabel.text = "must have at most \(data.maxLength) \(chars)"
        }
    }
}

extension ParraLongTextKindView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var answer: QuestionAnswer?
        if let text = textView.text {
            answer = QuestionAnswer(
                kind: .textShort,
                data: TextValueAnswer(value: text)
            )
        }

        updateValidation(text: textView.text)

        if validationError == .none {
            answerHandler.update(
                answer: answer,
                for: question
            )
        }
    }
}
