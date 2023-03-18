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

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.answerHandler = answerHandler
        self.question = question
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
            textView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        textView.applyConfig(config)
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

        answerHandler.update(
            answer: answer,
            for: question
        )
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        answerHandler.commitAnswers(for: question)
    }
}
