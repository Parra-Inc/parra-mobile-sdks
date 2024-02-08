//
//  ParraStarKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraStarKindView: UIView, ParraQuestionKindView {
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
        self.config = config
        self.starControl = ParraStarControl(
            starCount: data.starCount,
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

        starControl.translatesAutoresizingMaskIntoConstraints = false
        starControl.delegate = self
        contentContainer.addArrangedSubview(starControl)

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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    typealias DataType = StarQuestionBody
    typealias AnswerType = IntValueAnswer

    func applyConfig(_ config: ParraCardViewConfig) {
        starControl.applyConfig(config)
        ratingLabels?.applyConfig(config)
    }

    // MARK: Private

    private let question: Question
    private let answerHandler: ParraAnswerHandler
    private let config: ParraCardViewConfig
    private let starControl: ParraStarControl
    private let contentContainer = UIStackView(frame: .zero)
    private let ratingLabels: ParraRatingLabels?
    private let bucketId: String
}

// MARK: ParraStarControlDelegate

extension ParraStarKindView: ParraStarControlDelegate {
    func parraStarControl(
        _ control: ParraStarControl,
        didSelectStarCount count: Int
    ) {
        updateAnswer(for: count)
    }

    func parraStarControl(
        _ control: ParraStarControl,
        didConfirmStarCount count: Int
    ) {
        updateAnswer(for: count)
        answerHandler.commitAnswers(for: bucketId, question: question)
    }

    private func updateAnswer(for count: Int) {
        answerHandler.update(
            answer: QuestionAnswer(
                kind: .star,
                data: IntValueAnswer(value: count)
            ),
            for: bucketId
        )
    }
}
