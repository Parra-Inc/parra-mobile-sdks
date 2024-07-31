//
//  LegalInfoView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

class _LegalInfoView: UIView, UITextViewDelegate {
    // MARK: - Lifecycle

    init(
        legalInfo: LegalInfo,
        theme: ParraTheme
    ) {
        super.init(frame: .zero)

        addSubview(textView)

        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.isUserInteractionEnabled = true

        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        setContentHuggingPriority(.required, for: .vertical)

        updatedLegalInfo(legalInfo, with: theme)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: textView.intrinsicContentSize.width,
            height: 44.0
        )
    }

    func updatedLegalInfo(
        _ legalInfo: LegalInfo,
        with theme: ParraTheme
    ) {
        let baseAttributes = AttributeContainer(
            [
                .font: UIFont.preferredFont(forTextStyle: .footnote),
                .foregroundColor: UIColor(
                    theme.palette.secondaryText
                        .toParraColor()
                )
            ]
        )

        let linkAttributes = AttributeContainer(
            [
                .font: UIFont.preferredFont(forTextStyle: .footnote),
                .foregroundColor: UIColor(
                    theme.palette.secondaryText
                        .toParraColor()
                ),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor(theme.palette.primary.toParraColor())
            ]
        )

        var agreements = [LegalDocument]()
        if let privacyPolicy = legalInfo.privacyPolicy {
            agreements.append(privacyPolicy)
        }

        if let termsOfService = legalInfo.termsOfService {
            agreements.append(termsOfService)
        }

        let prefixBreak = agreements.count == 2 ? "\n" : " "
        let prefix = "By continuing, you agree to our\(prefixBreak)"

        var attributedString = AttributedString(
            prefix,
            attributes: baseAttributes
        )

        for (index, agreement) in agreements.enumerated() {
            var linkText = AttributedString(
                // Prevent line breaks within the agreement title
                agreement.title.replacingOccurrences(
                    of: " ",
                    with: "\u{a0}"
                ),
                attributes: linkAttributes
            )

            linkText.link = agreement.url

            attributedString.append(linkText)

            if index == agreements.count - 1 {
                attributedString.append(
                    AttributedString(
                        ".",
                        attributes: baseAttributes
                    )
                )
            } else if index == agreements.count - 2 {
                attributedString.append(
                    AttributedString(
                        " and ",
                        attributes: baseAttributes
                    )
                )
            } else {
                attributedString.append(
                    AttributedString(
                        ", ",
                        attributes: baseAttributes
                    )
                )
            }
        }

        textView.attributedText = NSAttributedString(attributedString)
        textView
            .textAlignment = .center // has to be set after changing the text
        textView.invalidateIntrinsicContentSize()
    }

    func textView(
        _ textView: UITextView,
        primaryActionFor textItem: UITextItem,
        defaultAction: UIAction
    ) -> UIAction? {
        if case .link(let url) = textItem.content {
            Logger.info("Tapping legal info link", [
                "url": url.absoluteString
            ])
        }

        return nil
    }

    // MARK: - Private

    private let textView = UITextView(frame: .zero)
}

struct LegalInfoView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(
        legalInfo: LegalInfo,
        theme: ParraTheme
    ) {
        self.legalInfo = legalInfo
        self.theme = theme
    }

    // MARK: - Internal

    let legalInfo: LegalInfo
    let theme: ParraTheme

    func makeUIView(
        context: Context
    ) -> _LegalInfoView {
        return _LegalInfoView(
            legalInfo: legalInfo,
            theme: theme
        )
    }

    func updateUIView(
        _ uiView: _LegalInfoView,
        context: Context
    ) {
        uiView.updatedLegalInfo(legalInfo, with: theme)
    }

    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: _LegalInfoView,
        context: Context
    ) -> CGSize? {
        let intrinsicContentSize = uiView.intrinsicContentSize

        return CGSize(
            width: proposal.width ?? intrinsicContentSize.width,
            height: intrinsicContentSize.height
        )
    }
}

#Preview {
    ParraViewPreview { _ in
        LegalInfoView(
            legalInfo: LegalInfo.validStates()[0],
            theme: .default
        )
    }
}
