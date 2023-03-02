//
//  ParraPaddedBaseButton.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

internal class ParraPaddedBaseButton: UIButton {
    private let forcedEdgeInsets: UIEdgeInsets

    required init(forcedEdgeInsets: UIEdgeInsets) {
        self.forcedEdgeInsets = forcedEdgeInsets

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let baseSize = super.intrinsicContentSize

        return CGSize(
            width: baseSize.width
                + titleEdgeInsets.left
                + titleEdgeInsets.right
                + forcedEdgeInsets.left
                + forcedEdgeInsets.right,
            height: baseSize.height
                + titleEdgeInsets.top
                + titleEdgeInsets.bottom
                + forcedEdgeInsets.top
                + forcedEdgeInsets.bottom
        )
    }
}
