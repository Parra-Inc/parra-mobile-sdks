//
//  ParraBorderedTextView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraBorderedTextView: UITextView, ParraLegacyConfigurableView {
    // MARK: - Lifecycle

    required init(config: ParraCardViewConfig) {
        self.config = config

        super.init(frame: .zero, textContainer: nil)

        textStorage.delegate = self
        scrollIndicatorInsets = UIEdgeInsets(
            top: 5,
            left: 0,
            bottom: 5,
            right: 0
        )
        textContainerInset = UIEdgeInsets(
            top: 14,
            left: 10,
            bottom: 14,
            right: 10
        )

        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.numberOfLines = 0

        addSubview(placeholderLabel)

        applyConfig(config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(forcedEdgeInsets: UIEdgeInsets) {
        fatalError("init(forcedEdgeInsets:) has not been implemented")
    }

    // MARK: - Internal

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        placeholderLabel.sizeToFit()

        let width = frame.width - textContainer
            .lineFragmentPadding * 2 - textContainerInset
            .left - textContainerInset.right
        let height = placeholderLabel.frame.height

        placeholderLabel.frame = CGRect(
            x: textContainer.lineFragmentPadding + textContainerInset.left,
            y: textContainerInset.top,
            width: width,
            height: height
        )
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()

        applyConfig(config)

        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()

        applyConfig(config)

        return result
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderWidth = 1.5

        let highlightColor = isFirstResponder
            ? config.accessoryTintColor
            : config.accessoryDisabledTintColor

        layer.borderColor = highlightColor?.cgColor
        tintColor = highlightColor

        font = config.body.font
        textColor = config.body.color

        placeholderLabel.font = config.body.font
        placeholderLabel.textColor = config.accessoryDisabledTintColor
    }

    // MARK: - Private

    private let placeholderLabel = UILabel(frame: .zero)
    private var config: ParraCardViewConfig
}

// MARK: NSTextStorageDelegate

extension ParraBorderedTextView: NSTextStorageDelegate {
    func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
}
