//
//  ParraShortTextKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraShortTextKindView: UIView, ParraQuestionKindView {
    // MARK: Lifecycle

    required init(
        bucketId: String,
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.question = question
        self.answerHandler = answerHandler
        self.bucketId = bucketId
        self.data = data
        self.textField = ParraBorderedTextField(config: config)

        super.init(frame: .zero)

        textField.placeholder = data.placeholder

        setup()
        applyConfig(config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    typealias DataType = ShortTextQuestionBody
    typealias AnswerType = TextValueAnswer

    func applyConfig(_ config: ParraCardViewConfig) {
        textField.applyConfig(config)
        validationLabel.font = config.label.font
    }

    func shouldAllowCommittingSelection() -> Bool {
        return validationError == .none
    }

    // MARK: Private

    private let question: Question
    private let data: DataType
    private let answerHandler: ParraAnswerHandler
    private let textField: ParraBorderedTextField
    private var validationError = TextValidationError.none
    private let validationLabel = UILabel(frame: .zero)
    private let bucketId: String

    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .yes
        textField.autocapitalizationType = .sentences
        textField.spellCheckingType = .yes
        textField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )

        addSubview(textField)

        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.textAlignment = .right
        validationLabel.textColor = Parra.Constants.brandColor

        addSubview(validationLabel)

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            textField.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            textField.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -8
            ),
            validationLabel.topAnchor.constraint(
                equalTo: textField.bottomAnchor,
                constant: 4
            ),
            validationLabel.trailingAnchor.constraint(
                equalTo: textField.trailingAnchor,
                constant: -4
            )
        ])
    }

    private func updateValidation(text: String) {
        validationError = validateText(text: text)

        switch validationError {
        case .none:
            validationLabel.text = nil
        case .minimum:
            let chars = data.minLength
                .simplePluralized(singularString: "character")
            validationLabel
                .text = "must have at least \(data.minLength) \(chars)"
        case .maximum:
            let chars = data.maxLength
                .simplePluralized(singularString: "character")
            validationLabel
                .text = "must have at most \(data.maxLength) \(chars)"
        }
    }

    @objc
    private func textDidChange() {
        guard validationError == .none else {
            return
        }

        var answer: QuestionAnswer?
        if let text = textField.text {
            answer = QuestionAnswer(
                kind: .textShort,
                data: TextValueAnswer(
                    value: text.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            )
        }

        answerHandler.update(
            answer: answer,
            for: bucketId
        )
    }

    private func validateText(text: String) -> TextValidationError {
        let minLength = data.minLength
        let maxLength = data.maxLength
        let textLength = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .count

        if textLength > maxLength {
            return .maximum
        } else if textLength < minLength {
            return .minimum
        } else {
            return .none
        }
    }
}

// MARK: UITextFieldDelegate

extension ParraShortTextKindView: UITextFieldDelegate {
    func textFieldDidEndEditing(
        _ textField: UITextField,
        reason: UITextField.DidEndEditingReason
    ) {
        if validationError == .none {
            answerHandler.commitAnswers(for: bucketId, question: question)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return validationError == .none
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(
            in: stringRange,
            with: string
        )

        updateValidation(text: updatedText)

        return true
    }
}
