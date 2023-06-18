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
    private let config: ParraCardViewConfig
    private let ratingControl: ParraBorderedRatingControl
    private let contentContainer = UIStackView(frame: .zero)
    private let ratingLabels: ParraRatingLabels?
    private let bucketId: String

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
        self.config = config
        self.ratingControl = ParraBorderedRatingControl(
            options: data.options,
            config: config
        )
        self.ratingLabels = ParraRatingLabels(
            leadingText: data.leadingLabel,
            centerText: data.centerLabel,
            trailingText: data.trailingLabel
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

        if let ratingLabels {
            ratingLabels.translatesAutoresizingMaskIntoConstraints = false
            contentContainer.addArrangedSubview(ratingLabels)
        }

        addSubview(contentContainer)

        contentContainer.activateEdgeConstraintsWithVerticalCenteringPreference(
            to: self,
            with: .parraDefaultCardContentPadding
        )

        applyConfig(config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        ratingControl.applyConfig(config)
        ratingLabels?.applyConfig(config)
    }
}

extension ParraRatingKindView: ParraBorderedRatingControlDelegate {
    func parraBorderedRatingControl(_ control: ParraBorderedRatingControl,
                                    didSelectOption option: RatingQuestionOption) {

        updateAnswer(for: option)
    }

    func parraBorderedRatingControl(_ control: ParraBorderedRatingControl,
                                    didConfirmOption option: RatingQuestionOption) {

        updateAnswer(for: option)
        answerHandler.commitAnswers(for: bucketId, question: question)
    }

    private func updateAnswer(for option: RatingQuestionOption) {
        answerHandler.update(
            answer: QuestionAnswer(
                kind: .rating,
                data: SingleOptionAnswer(optionId: option.id)
            ),
            for: bucketId
        )
    }
}
