//
//  ParraBorderedButton.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

protocol ParraBorderedButtonDelegate: AnyObject {
    func buttonShouldSelect(button: ParraBorderedButton, optionId: String)
        -> Bool
    func buttonDidSelect(button: ParraBorderedButton, optionId: String)
    func buttonDidDeselect(button: ParraBorderedButton, optionId: String)
}

#Preview {
    let stack = UIStackView(
        arrangedSubviews: [
            ParraBorderedButton(
                title: "Test Button 1",
                optionId: "aaaa",
                isInitiallySelected: false,
                config: .default
            ),
            ParraBorderedButton(
                title: "Test Button 2",
                optionId: "bbbb",
                isInitiallySelected: true,
                config: .default
            ),
            ParraBorderedButton(
                title: "Test Button 3",
                optionId: "cccc",
                isInitiallySelected: false,
                config: .default
            )
        ]
    )

    stack.axis = .vertical
    stack.spacing = 20
    stack.distribution = .equalCentering

    return stack
}

class ParraBorderedButton: UIView, ParraLegacyConfigurableView {
    // MARK: - Lifecycle

    required init(
        title: String,
        optionId: String,
        isInitiallySelected: Bool,
        config: ParraCardViewConfig
    ) {
        self.isSelected = isInitiallySelected
        self.title = title
        self.optionId = optionId
        self.config = config

        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    var config: ParraCardViewConfig

    weak var delegate: ParraBorderedButtonDelegate?

    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderWidth = 1.5

        innerButton.translatesAutoresizingMaskIntoConstraints = false
        innerButton.setTitle(title, for: .normal)
        innerButton.addTarget(
            self,
            action: #selector(buttonShouldHighlight),
            for: [.touchDown, .touchDragEnter]
        )
        innerButton.addTarget(
            self,
            action: #selector(buttonDidEndSelect),
            for: .touchUpInside
        )
        innerButton.addTarget(
            self,
            action: #selector(buttonDidCancelSelect),
            for: [
                .touchUpOutside,
                .touchCancel,
                .touchDragExit
            ]
        )

        addSubview(innerButton)

        NSLayoutConstraint.activate([
            innerButton.topAnchor.constraint(equalTo: topAnchor),
            innerButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            innerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        applyConfig(config)
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        backgroundColor = isHighlighted ? config
            .accessoryDisabledTintColor : config.backgroundColor

        innerButton.titleLabel?.font = config.body.font
        innerButton.setTitleColor(config.body.color, for: .normal)
        innerButton.setTitleColor(config.body.color, for: .highlighted)
        innerButton.setTitleShadowColor(config.body.shadow.color, for: .normal)

        layer.borderColor = isSelected || isHighlighted ? config
            .accessoryTintColor?.cgColor : config.accessoryDisabledTintColor?
            .cgColor
    }

    @objc
    func buttonShouldHighlight(_ sender: ParraPaddedBaseButton) {
        let canSelect = delegate?.buttonShouldSelect(
            button: self,
            optionId: optionId
        ) ?? false

        if canSelect {
            applyWithAnimation { [self] in
                isHighlighted = true
            }
        }
    }

    @objc
    func buttonDidEndSelect(_ sender: ParraPaddedBaseButton) {
        let canSelect = delegate?.buttonShouldSelect(
            button: self,
            optionId: optionId
        ) ?? false

        if canSelect {
            applyWithAnimation { [self] in
                isHighlighted = false
                isSelected.toggle()
            }
        }
    }

    @objc
    func buttonDidCancelSelect(_ sender: ParraPaddedBaseButton) {
        applyWithAnimation { [self] in
            isHighlighted = false
            isSelected = false
        }
    }

    // MARK: - Private

    private let innerButton = ParraPaddedBaseButton(
        forcedEdgeInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    )

    private let title: String
    private let optionId: String

    private var isSelected: Bool {
        didSet {
            if isSelected == oldValue {
                return
            }

            applyConfig(config)

            if isSelected {
                delegate?.buttonDidSelect(button: self, optionId: optionId)
            } else {
                delegate?.buttonDidDeselect(button: self, optionId: optionId)
            }
        }
    }

    private var isHighlighted: Bool = false {
        didSet {
            applyConfig(config)
        }
    }

    private func applyWithAnimation(
        changes: @escaping () -> Void
    ) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                changes()
            },
            completion: nil
        )
    }
}
