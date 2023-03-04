//
//  ParraRatingKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/12/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraRatingKindView: UIView, ParraQuestionKindView {
    typealias DataType = RatingQuestionBody
    typealias AnswerType = SingleOptionAnswer

    private let question: Question
    private let answerHandler: ParraAnswerHandler
    private let ratingControl: ParraBorderedRatingControl
    private let contentContainer = UIStackView(frame: .zero)
    private let bottomBar: UIStackView?

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.question = question
        self.answerHandler = answerHandler

        let requiresBottomBar = data.leadingLabel != nil || data.centerLabel != nil || data.trailingLabel != nil
        if requiresBottomBar {
            let leadingLabel = UILabel(frame: .zero)
            let centerLabel = UILabel(frame: .zero)
            let trailingLabel = UILabel(frame: .zero)

            leadingLabel.text = data.leadingLabel
            leadingLabel.textAlignment = .left

            centerLabel.text = data.centerLabel
            centerLabel.textAlignment = .center

            trailingLabel.text = data.trailingLabel
            trailingLabel.textAlignment = .right

            let bottomBar = UIStackView(frame: .zero)
            let labels = [(leadingLabel, "Leading"), (centerLabel, "Center"), (trailingLabel, "Trailing")]
            for (label, alignment) in labels {
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 2
                label.lineBreakMode = .byWordWrapping
                label.accessibilityIdentifier = "ParraRating\(alignment)Label"
                if #available(iOS 14.0, *) {
                    label.lineBreakStrategy = .standard
                }

                bottomBar.addArrangedSubview(label)
            }

            self.bottomBar = bottomBar
        } else {
            bottomBar = nil
        }

        ratingControl = ParraBorderedRatingControl(
            options: data.options,
            config: config
        )

        super.init(frame: .zero)

        contentContainer.axis = .vertical
        contentContainer.alignment = .fill
        contentContainer.spacing = 12.0
        contentContainer.distribution = .equalCentering
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        ratingControl.translatesAutoresizingMaskIntoConstraints = false
        ratingControl.delegate = self
        contentContainer.addArrangedSubview(ratingControl)

        if let bottomBar {
            bottomBar.axis = .horizontal
            bottomBar.alignment = .center
            bottomBar.spacing = 24
            bottomBar.distribution = .fillEqually
            bottomBar.translatesAutoresizingMaskIntoConstraints = false

            contentContainer.addArrangedSubview(bottomBar)
        }

        addSubview(contentContainer)

        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            contentContainer.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -8
            ),
            contentContainer.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            contentContainer.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 8
            ),
            contentContainer.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -8
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        ratingControl.applyConfig(config)

        guard let bottomBar else {
            return
        }

        for view in bottomBar.arrangedSubviews {
            guard let label = view as? UILabel else {
                continue
            }

            label.font = config.label.font
            label.textColor = config.label.color
        }
    }
}

extension ParraRatingKindView: ParraBorderedRatingControlDelegate {
    func parraBorderedRatingControl(_ control: ParraBorderedRatingControl,
                                    didSelectOption option: RatingQuestionOption) {

        answerHandler.update(
            answer: QuestionAnswer(
                kind: .rating,
                data: SingleOptionAnswer(optionId: option.id)
            ),
            for: question
        )

        answerHandler.commitAnswers(for: question)
    }
}
