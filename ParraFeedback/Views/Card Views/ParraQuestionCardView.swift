//
//  ParraQuestionCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraCore

internal class ParraQuestionCardView: ParraCardItemView {
    internal enum Constant {
        static let bottomPadding: CGFloat = 8.0
        static let horizontalPadding: CGFloat = 10.0
        static let contentPadding: CGFloat = 6.0
    }

    internal override var config: ParraCardViewConfig {
        didSet {
            applyConfig(config)
        }
    }

    private let question: Question
    private let answerHandler: ParraCardAnswerHandler
    private var questionTypeView: any (UIView & ParraQuestionKindView)

    private let titleLabel: UILabel
    private var subtitleLabel: UILabel?

    internal required init(question: Question,
                           answerHandler: ParraCardAnswerHandler,
                           config: ParraCardViewConfig) {
        self.question = question
        self.answerHandler = answerHandler

        titleLabel = UILabel(frame: .zero)

        switch question.data {
        case .booleanQuestionBody(let data):
            questionTypeView = ParraBooleanKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .checkboxQuestionBody(let data):
            questionTypeView = ParraCheckboxKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .choiceQuestionBody(let data):
            questionTypeView = ParraChoiceKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .imageQuestionBody(let data):
            questionTypeView = ParraImageKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .longTextQuestionBody(let data):
            questionTypeView = ParraLongTextKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .ratingQuestionBody(let data):
            questionTypeView = ParraRatingKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .shortTextQuestionBody(let data):
            questionTypeView = ParraShortTextKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        case .starQuestionBody(let data):
            questionTypeView = ParraStarKindView(
                question: question,
                data: data,
                config: config,
                answerHandler: answerHandler
            )
        }

        super.init(config: config)

        translatesAutoresizingMaskIntoConstraints = false
        questionTypeView.translatesAutoresizingMaskIntoConstraints = false
        questionTypeView.setContentHuggingPriority(.defaultLow, for: .vertical)

        titleLabel.text = question.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        if #available(iOS 14.0, *) {
            titleLabel.lineBreakStrategy = .hangulWordPriority
        }
        titleLabel.isUserInteractionEnabled = true
        titleLabel.accessibilityIdentifier = "Parra Question Title Label"

        addSubview(titleLabel)
        addSubview(questionTypeView)

        var constraints: [NSLayoutConstraint] = [
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constant.horizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constant.horizontalPadding
            ),
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),
            questionTypeView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            questionTypeView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -8
            ),
            questionTypeView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constant.bottomPadding
            )
        ]

        if let subtitle = question.subtitle {
            let subtitleLabel = UILabel(frame: .zero)

            subtitleLabel.text = subtitle
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.numberOfLines = 2
            subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
            subtitleLabel.isUserInteractionEnabled = true
            subtitleLabel.accessibilityIdentifier = "Parra Question Subtitle Label"

            self.subtitleLabel = subtitleLabel

            addSubview(subtitleLabel)

            constraints.append(contentsOf: [
                subtitleLabel.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: Constant.horizontalPadding
                ),
                subtitleLabel.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -Constant.horizontalPadding
                ),
                subtitleLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Constant.contentPadding
                ),
                questionTypeView.topAnchor.constraint(
                    equalTo: subtitleLabel.bottomAnchor,
                    constant: Constant.contentPadding
                )
            ])
        } else {
            constraints.append(
                questionTypeView.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Constant.contentPadding
                )
            )
        }

        NSLayoutConstraint.activate(constraints)

        applyConfig(config)
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal required init(config: ParraCardViewConfig) {
        fatalError("init(config:) has not been implemented")
    }

    internal override func applyConfig(_ config: ParraCardViewConfig) {
        titleLabel.font = config.title.font
        titleLabel.textColor = config.title.color
        titleLabel.layer.shadowColor = config.title.shadow.color.cgColor
        titleLabel.layer.shadowOffset = config.title.shadow.offset
        titleLabel.layer.shadowRadius = config.title.shadow.radius
        titleLabel.layer.shadowOpacity = config.title.shadow.opacity

        if let subtitleLabel = subtitleLabel {
            subtitleLabel.font = config.subtitle.font
            subtitleLabel.textColor = config.subtitle.color
            subtitleLabel.layer.shadowColor = config.subtitle.shadow.color.cgColor
            subtitleLabel.layer.shadowOffset = config.subtitle.shadow.offset
            subtitleLabel.layer.shadowRadius = config.subtitle.shadow.radius
            subtitleLabel.layer.shadowOpacity = config.subtitle.shadow.opacity
        }

        questionTypeView.applyConfig(config)
    }
}

