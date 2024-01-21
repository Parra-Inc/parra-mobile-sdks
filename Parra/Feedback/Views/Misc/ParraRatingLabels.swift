//
//  ParraRatingLabels.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal class ParraRatingLabels: UIView, ParraLegacyConfigurableView {
    required init?(leadingText: String?, centerText: String?, trailingText: String?) {
        if leadingText == nil && centerText == nil && trailingText == nil {
            return nil
        }

        super.init(frame: .zero)

        let leadingLabel = UILabel(frame: .zero)
        let centerLabel = UILabel(frame: .zero)
        let trailingLabel = UILabel(frame: .zero)

        leadingLabel.text = leadingText
        centerLabel.text = centerText
        trailingLabel.text = trailingText

        applyCommonAttributes(to: leadingLabel, named: "Leading")
        applyCommonAttributes(to: centerLabel, named: "Center")
        applyCommonAttributes(to: trailingLabel, named: "Trailing")

        addSubview(leadingLabel)
        addSubview(centerLabel)
        addSubview(trailingLabel)

        var constraints = [NSLayoutConstraint]()
        constraints.append(
            contentsOf: leadingLabel.constrainEdges(edges: [.leading, .top, .bottom], to: self)
        )
        constraints.append(
            contentsOf: centerLabel.constrainEdges(edges: [.top, .bottom], to: self)
        )
        constraints.append(
            contentsOf: trailingLabel.constrainEdges(edges: [.trailing, .top, .bottom], to: self)
        )
        constraints.append(contentsOf: [
            centerLabel.heightAnchor.constraint(equalTo: leadingLabel.heightAnchor),
            trailingLabel.heightAnchor.constraint(equalTo: centerLabel.heightAnchor),
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            leadingLabel.trailingAnchor.constraint(lessThanOrEqualTo: centerLabel.leadingAnchor, constant: -16),
            trailingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: centerLabel.trailingAnchor, constant: 16),
            leadingLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.25),
            centerLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.25),
            trailingLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.25),
        ])

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        for view in subviews {
            guard let label = view as? UILabel else {
                continue
            }

            label.font = config.label.font
            label.textColor = config.label.color
        }
    }

    private func applyCommonAttributes(to label: UILabel,
                                       named name: String) {

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.accessibilityIdentifier = "ParraRating\(name)Label"
        label.lineBreakStrategy = .standard
    }
}
