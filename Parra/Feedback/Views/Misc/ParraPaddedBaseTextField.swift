//
//  ParraPaddedBaseTextField.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/27/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

internal class ParraPaddedBaseTextField: UITextField {
    private let forcedEdgeInsets: UIEdgeInsets

    required init(forcedEdgeInsets: UIEdgeInsets) {
        self.forcedEdgeInsets = forcedEdgeInsets

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds)
            .inset(by: forcedEdgeInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds)
            .inset(by: forcedEdgeInsets)
    }
}