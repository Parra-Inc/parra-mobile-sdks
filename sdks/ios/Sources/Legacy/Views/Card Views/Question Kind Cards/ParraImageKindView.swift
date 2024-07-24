//
//  ParraImageKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraImageKindView: UIView, ParraQuestionKindView {
    // MARK: - Lifecycle

    required init(
        bucketId: String,
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraCardAnswerHandler
    ) {
        assert(data.options.count <= 3)

        self.question = question
        self.config = config
        self.answerHandler = answerHandler
        self.bucketId = bucketId

        super.init(frame: .zero)

        contentContainer.axis = .horizontal
        contentContainer.alignment = .fill
        contentContainer.spacing = 40.0
        contentContainer.distribution = .fillEqually
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentContainer)

        var constraints = [NSLayoutConstraint]()

        for option in data.options {
            let optionContainer = UIView(frame: .zero)
            optionContainer.translatesAutoresizingMaskIntoConstraints = false

            let imageButton = ParraImageButton(
                initiallySelected: false,
                config: config,
                asset: option.asset
            )

            imageButton.translatesAutoresizingMaskIntoConstraints = false
            imageButton.delegate = self
            buttonOptionMap[imageButton] = option

            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = option.title
            label.numberOfLines = 1
            label.textAlignment = .center

            labels.append(label)

            optionContainer.addSubview(imageButton)
            optionContainer.addSubview(label)

            contentContainer.addArrangedSubview(optionContainer)

            constraints.append(
                contentsOf: imageButton.constrainEdges(
                    edges: [.leading, .top, .trailing],
                    to: optionContainer,
                    with: .zero
                )
            )

            constraints.append(
                label.topAnchor.constraint(
                    equalTo: imageButton.bottomAnchor,
                    constant: 8
                )
            )

            constraints.append(
                contentsOf: label.constrainEdges(
                    edges: [.leading, .bottom, .trailing],
                    to: optionContainer,
                    with: .zero
                )
            )
        }

        constraints.append(contentsOf: [
            contentContainer.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: UIEdgeInsets.parraDefaultCardContentPadding.left
            ),
            contentContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -UIEdgeInsets.parraDefaultCardContentPadding.right
            ),
            contentContainer.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),
            contentContainer.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            contentContainer.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: UIEdgeInsets.parraDefaultCardContentPadding.top
            ),
            contentContainer.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -UIEdgeInsets.parraDefaultCardContentPadding.bottom
            )
        ])

        NSLayoutConstraint.activate(constraints)

        applyConfig(config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    typealias DataType = ImageQuestionBody
    typealias AnswerType = SingleOptionAnswer

    func applyConfig(_ config: ParraCardViewConfig) {
        for imageButton in buttonOptionMap.keys {
            imageButton.applyConfig(config)
        }

        for label in labels {
            label.font = config.title.font
            label.textColor = config.title.color
        }
    }

    // MARK: - Private

    private let question: Question
    private let answerHandler: ParraCardAnswerHandler
    private let bucketId: String
    private let config: ParraCardViewConfig
    private let contentContainer = UIStackView(frame: .zero)

    private var buttonOptionMap = [ParraImageButton: ImageQuestionOption]()
    private var labels = [UILabel]()
}

// MARK: SelectableButtonDelegate

extension ParraImageKindView: SelectableButtonDelegate {
    func buttonDidSelect(button: SelectableButton) {
        guard let imageButton = button as? ParraImageButton,
              let option = buttonOptionMap[imageButton] else
        {
            return
        }

        answerHandler.update(
            answer: QuestionAnswer(
                kind: .image,
                data: AnswerType(optionId: option.id)
            ),
            for: bucketId
        )

        answerHandler.commitAnswers(for: bucketId, question: question)
    }

    func buttonDidDeselect(button: SelectableButton) {}
}
