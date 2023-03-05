//
//  ParraShortTextKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraShortTextKindView: UIView, ParraQuestionKindView {
    typealias DataType = ShortTextQuestionBody
    typealias AnswerType = TextValueAnswer

    private let answerHandler: ParraAnswerHandler
    private let textField: ParraBorderedTextField
    private let question: Question

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.answerHandler = answerHandler
        self.question = question
        self.textField = ParraBorderedTextField(config: config)

        super.init(frame: .zero)

        textField.placeholder = data.placeholder

        setup()
        applyConfig(config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .yes
        textField.autocapitalizationType = .sentences
        textField.spellCheckingType = .yes
        textField.addTarget(self,
                            action: #selector(self.textDidChange),
                            for: .editingChanged)

        addSubview(textField)

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
        ])
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        textField.applyConfig(config)
    }

    @objc private func textDidChange() {
        var answer: QuestionAnswer?
        if let text = textField.text {
            answer = QuestionAnswer(
                kind: .textShort,
                data: TextValueAnswer(value: text)
            )
        }

        answerHandler.update(
            answer: answer,
            for: question
        )
    }
}

extension ParraShortTextKindView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField,
                                reason: UITextField.DidEndEditingReason) {

        answerHandler.commitAnswers(for: question)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}

