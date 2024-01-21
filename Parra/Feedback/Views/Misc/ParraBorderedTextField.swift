//
//  ParraBorderedTextField.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/28/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

class ParraBorderedTextField: ParraPaddedBaseTextField, ParraLegacyConfigurableView {
    private var config: ParraCardViewConfig

    required init(config: ParraCardViewConfig) {
        self.config = config

        super.init(
            forcedEdgeInsets: UIEdgeInsets(
                top: 18,
                left: 14,
                bottom: 18,
                right: 14
            )
        )

        applyConfig(config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(forcedEdgeInsets: UIEdgeInsets) {
        fatalError("init(forcedEdgeInsets:) has not been implemented")
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
    }
}

