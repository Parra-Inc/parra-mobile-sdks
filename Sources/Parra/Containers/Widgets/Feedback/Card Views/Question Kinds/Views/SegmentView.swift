//
//  SegmentView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct SegmentView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(
        options: [SegmentControl.Option],
        style: ParraAttributedSegmentStyle,
        onSelect: ((_: SegmentControl.Option) -> Void)? = nil,
        onConfirm: ((_: SegmentControl.Option) -> Void)? = nil
    ) {
        self.options = options
        self.style = style
        self.onSelect = onSelect
        self.onConfirm = onConfirm
    }

    // MARK: - Internal

    let options: [SegmentControl.Option]
    let style: ParraAttributedSegmentStyle
    let onSelect: ((_ option: SegmentControl.Option) -> Void)?
    let onConfirm: ((_ option: SegmentControl.Option) -> Void)?

    func makeUIView(
        context: Context
    ) -> SegmentControl {
        SegmentControl(
            options: options,
            style: style,
            onSelect: onSelect,
            onConfirm: onConfirm
        )
    }

    func updateUIView(
        _ uiView: SegmentControl,
        context: Context
    ) {
        uiView.appleStyle(style)
    }

    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: SegmentControl,
        context: Context
    ) -> CGSize? {
        let intrinsicContentSize = uiView.intrinsicContentSize

        return CGSize(
            width: proposal.width ?? intrinsicContentSize.width,
            height: intrinsicContentSize.height
        )
    }
}

class SegmentControl: UIControl {
    // MARK: - Lifecycle

    required init(
        options: [Option],
        style: ParraAttributedSegmentStyle,
        onSelect: ((_ option: Option) -> Void)?,
        onConfirm: ((_ option: Option) -> Void)?
    ) {
        self.style = style
        self.onSelect = onSelect
        self.onConfirm = onConfirm

        assert(
            options.count <= 10,
            "The layout of this control was never considered with this many options"
        )

        super.init(frame: .zero)

        layer.masksToBounds = true

        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.isUserInteractionEnabled = false
        labelStack.axis = .horizontal
        labelStack.spacing = 0
        labelStack.alignment = .fill
        labelStack.distribution = .fillEqually

        for option in options {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = false
            label.textAlignment = .center
            label.layer.borderWidth = 0.5

            optionLabelMap[label] = option

            labelStack.addArrangedSubview(label)
        }

        addSubview(labelStack)

        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            labelStack.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            labelStack.topAnchor.constraint(
                equalTo: topAnchor
            ),
            labelStack.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])

        appleStyle(style)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    struct Option: Equatable {
        let id: String
        let title: String
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: labelStack.intrinsicContentSize.width,
            height: 54
        )
    }

    override func beginTracking(
        _ touch: UITouch,
        with event: UIEvent?
    ) -> Bool {
        respondToTouchChange(touch: touch, with: event)

        return super.beginTracking(touch, with: event)
    }

    override func continueTracking(
        _ touch: UITouch,
        with event: UIEvent?
    ) -> Bool {
        respondToTouchChange(touch: touch, with: event)

        return super.continueTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch {
            respondToTouchChange(touch: touch, with: event)
        }

        return super.endTracking(touch, with: event)
    }

    func appleStyle(_ style: ParraAttributedSegmentStyle) {
        let attributes = style.attributes

        var corners = CACornerMask()
        let cornerRadius = style.theme.cornerRadius.value(
            for: attributes.cornerRadius
        )

        if cornerRadius.topLeading != 0 {
            corners.insert(.layerMinXMinYCorner)
        }
        if cornerRadius.topTrailing != 0 {
            corners.insert(.layerMaxXMinYCorner)
        }
        if cornerRadius.bottomLeading != 0 {
            corners.insert(.layerMinXMaxYCorner)
        }
        if cornerRadius.bottomTrailing != 0 {
            corners.insert(.layerMaxXMaxYCorner)
        }

        layer.maskedCorners = corners
        layer.cornerRadius = cornerRadius.topLeading
        layer.borderColor = if let borderColor = attributes.borderColor {
            UIColor(borderColor).cgColor
        } else {
            nil
        }
        layer.borderWidth = attributes.borderWidth ?? 1.5

        for subview in labelStack.arrangedSubviews {
            guard let label = subview as? UILabel else {
                continue
            }

            guard let option = optionLabelMap[label] else {
                continue
            }

            var container = AttributeContainer()

            if option == highlightedOption {
//                container.font = attributes.optionLabelsSelected.font
//                if let fontColor = attributes.optionLabelsSelected.fontColor {
//                    container.foregroundColor = UIColor(fontColor)
//                }
//
//                if let background = attributes.optionLabelsSelected.background {
                ////                    background.
//                }

                label.backgroundColor = .red
            } else {
                container.font = attributes.optionLabels.font
                if let fontColor = attributes.optionLabels.fontColor {
                    container.foregroundColor = UIColor(fontColor)
                }

                label.backgroundColor = .blue
            }

            label.layer.borderWidth = 0.5
            if let borderColor = attributes.borderColor {
                label.layer.borderColor = UIColor(borderColor).cgColor
            }

            label.attributedText = NSAttributedString(
                AttributedString(option.title, attributes: container)
            )

            // Setting the background color on the labels layer is necessary to support animation
//            label.layer.backgroundColor = option == highlightedOption
//                ? config.accessoryTintColor?.cgColor : UIColor.clear.cgColor

            setNeedsDisplay()
        }
    }

    // MARK: - Private

    private let style: ParraAttributedSegmentStyle

    private let onSelect: ((_ option: Option) -> Void)?
    private let onConfirm: ((_ option: Option) -> Void)?

    private let labelStack = UIStackView(frame: .zero)
    private var highlightedOption: Option?

    private var optionLabelMap = [UILabel: Option]()

    private func respondToTouchChange(touch: UITouch, with event: UIEvent?) {
        guard let label = labelBelow(touch: touch, with: event) else {
            return
        }

        guard let nextHightedOption = optionLabelMap[label] else {
            return
        }

        if nextHightedOption == highlightedOption {
            if touch.phase == .ended {
                onConfirm?(nextHightedOption)
            }

            return
        }

        highlightedOption = nextHightedOption

        UIView.animate(
            withDuration: 0.15,
            delay: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) { [self] in
            appleStyle(style)
        } completion: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.onSelect?(nextHightedOption)
        }
    }

    private func labelBelow(touch: UITouch, with event: UIEvent?) -> UILabel? {
        let touchLocation = labelStack.convert(
            touch.location(in: self),
            from: self
        )

        for subview in labelStack.arrangedSubviews {
            guard let label = subview as? UILabel else {
                continue
            }

            if label.frame.contains(touchLocation) {
                return label
            }
        }

        return nil
    }
}
