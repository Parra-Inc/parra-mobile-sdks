//
//  ParraPaddedBaseTextField.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/27/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraPaddedBaseTextField: UITextField {
    // MARK: Lifecycle

    required init(forcedEdgeInsets: UIEdgeInsets) {
        self.forcedEdgeInsets = forcedEdgeInsets

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds)
            .inset(by: forcedEdgeInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds)
            .inset(by: forcedEdgeInsets)
    }

    // MARK: Private

    private let forcedEdgeInsets: UIEdgeInsets
}
