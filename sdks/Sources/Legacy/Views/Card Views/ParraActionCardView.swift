//
//  ParraActionCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit

class ParraActionCardView: ParraCardItemView {
    // MARK: - Lifecycle

    required init(
        config: ParraCardViewConfig,
        title: String,
        subtitle: String?,
        actionTitle: String,
        actionHandler: (() -> Void)?
    ) {
        super.init(config: config)

        translatesAutoresizingMaskIntoConstraints = false

        self.actionHandler = actionHandler

        stackView.addArrangedSubview(titleLabel)
        if let subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.font = .preferredFont(forTextStyle: .callout)
            subtitleLabel.numberOfLines = 3
            subtitleLabel.lineBreakMode = .byTruncatingTail
            subtitleLabel.textAlignment = .center

            stackView.addArrangedSubview(subtitleLabel)
        }
        stackView.addArrangedSubview(cta)

        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: ParraCardView.LayoutConstants.contentPadding
            ),
            stackView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -ParraCardView.LayoutConstants.contentPadding
            ),
            // visually centered
            stackView.centerYAnchor.constraint(
                equalTo: centerYAnchor,
                constant: -ParraCardView.LayoutConstants.navigationPadding
            ),
            stackView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 0
            ),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: 0
            )
        ])

        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail

        cta.addTarget(
            self,
            action: #selector(ctaPressed(button:)),
            for: .touchUpInside
        )

        let attributedTitle = NSAttributedString(
            string: actionTitle,
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        cta.setAttributedTitle(attributedTitle, for: .normal)
        cta.translatesAutoresizingMaskIntoConstraints = false
        cta.setTitleColor(UIColor(hex: 0xBDBDBD), for: .normal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(config: ParraCardViewConfig) {
        fatalError("init(config:) has not been implemented")
    }

    // MARK: - Private

    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    private var cta = UIButton(type: .system)
    private let stackView = UIStackView(arrangedSubviews: [])
    private var actionHandler: (() -> Void)?

    @objc
    private func ctaPressed(button: UIButton) {
        if let actionHandler {
            actionHandler()
        }
    }
}
