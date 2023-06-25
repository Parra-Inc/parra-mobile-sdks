//
//  UIView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

internal struct Edges: OptionSet {
    let rawValue: Int

    static let top          = Edges(rawValue: 1 << 0)
    static let bottom       = Edges(rawValue: 1 << 1)
    static let leading      = Edges(rawValue: 1 << 2)
    static let trailing     = Edges(rawValue: 1 << 3)

    static let all: Edges   = [.top, .bottom, .leading, .trailing]
}

internal extension UIView {
    func activateEdgeConstraints(to view: UIView,
                                 with insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate(
            constrainEdges(to: view, with: insets)
        )
    }

    func activateEdgeConstraintsWithVerticalCenteringPreference(to view: UIView,
                                                                with insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate(
            constrainEdgesWithVerticalCenteringPreference(to: view, with: insets)
        )
    }

    func constrainEdges(edges: Edges = .all,
                        to view: UIView,
                        with insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        if edges.contains(.leading) || edges.contains(.all) {
            constraints.append(
                leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: insets.left
                )
            )
        }

        if edges.contains(.trailing) || edges.contains(.all) {
            constraints.append(
                trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -insets.right
                )
            )
        }

        if edges.contains(.top) || edges.contains(.all) {
            constraints.append(
                topAnchor.constraint(
                    equalTo: view.topAnchor,
                    constant: insets.top
                )
            )
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            constraints.append(
                bottomAnchor.constraint(
                    equalTo: view.bottomAnchor,
                    constant: -insets.bottom
                )
            )
        }

        return constraints
    }

    func constrainEdgesWithVerticalCenteringPreference(to view: UIView,
                                                       with insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: insets.left
            ),
            trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -insets.right
            ),
            centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            topAnchor.constraint(
                greaterThanOrEqualTo: view.topAnchor,
                constant: insets.top
            ),
            bottomAnchor.constraint(
                lessThanOrEqualTo: view.bottomAnchor,
                constant: -insets.bottom
            )
        ]
    }
}
