//
//  ParraPaddedBaseButton.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraPaddedBaseButton: UIButton {
    // MARK: - Lifecycle

    required init(forcedEdgeInsets: UIEdgeInsets) {
        self.forcedEdgeInsets = forcedEdgeInsets

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    override var intrinsicContentSize: CGSize {
        let baseSize = super.intrinsicContentSize
        let insets = configuration?.contentInsets ?? .zero

        return CGSize(
            width: baseSize.width
                + insets.leading
                + insets.trailing
                + forcedEdgeInsets.left
                + forcedEdgeInsets.right,
            height: baseSize.height
                + insets.top
                + insets.bottom
                + forcedEdgeInsets.top
                + forcedEdgeInsets.bottom
        )
    }

    // MARK: - Private

    private let forcedEdgeInsets: UIEdgeInsets
}
